defmodule Questify.TextHandler do
  use GenServer

  @topic "generations"
  @done "[DONE]"

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, nil}
  end

  def get_completion(text) do
    text_model = "gpt-3.5-turbo"
    openai_api_key = Application.get_env(:questify, :openai)[:openai_api_key]
    openai_completion_url = "https://api.openai.com/v1/chat/completions"

    # Setup the request data
    request_data = setup_request_data(text_model, text, false)

    # Make the request, get the response
    do_post(openai_completion_url, request_data, openai_api_key)
  end

  def stream_completion(hash, text) do
    text_model = "gpt-3.5-turbo"
    openai_api_key = Application.get_env(:questify, :openai)[:openai_api_key]
    openai_completion_url = "https://api.openai.com/v1/chat/completions"

    # Setup the request data
    request_data = setup_request_data(text_model, text, true)

    # Cast for async post and streaming response
    GenServer.cast(
      __MODULE__,
      {:stream_text, hash, openai_completion_url, request_data, openai_api_key}
    )
  end

  @impl true
  def handle_cast({:stream_text, hash, url, request_data, api_key}, _state) do
    opts = [recv_timeout: 30_000, timeout: 30_000, stream_to: self()]

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{api_key}"}
    ]

    HTTPoison.post!(
      url,
      request_data,
      headers,
      opts
    )

    stream_next(hash)

    {:noreply, nil}
  end

  @impl true
  def handle_info(msg, _state) do
    IO.inspect(msg, label: "unexpected msg received")
    {:noreply, nil}
  end

  def broadcast_chunk(hash, text) do
    Phoenix.PubSub.broadcast!(Questify.PubSub, @topic, %Phoenix.Socket.Broadcast{
      topic: @topic,
      event: "text_update",
      payload: {:text_update, hash, text}
    })
  end

  def broadcast_complete(hash) do
    Phoenix.PubSub.broadcast!(Questify.PubSub, @topic, %Phoenix.Socket.Broadcast{
      topic: @topic,
      event: "text_complete",
      payload: {:text_complete, hash}
    })
  end

  defp stream_next(hash) do
    receive do
      chunk = %HTTPoison.AsyncChunk{} ->
        data =
          chunk.chunk
          |> String.split("\n")
          |> Enum.map(fn x ->
            x
            |> String.replace_prefix("data: ", "")
            |> String.trim()
          end)
          |> Enum.filter(fn x -> x != "" end)
          |> Enum.map(fn x ->
            handle_chunk(hash, x)
          end)


        last = Enum.reverse(data) |> hd()

        if last != @done do
          stream_next(hash)
        end

      %HTTPoison.AsyncEnd{} ->
        broadcast_complete(hash)

      {:http_error, _reason} ->
        IO.puts("HTTP error")

      {:done, _status} ->
        IO.puts("Done streaming.")

      # Match against other messages you might expect, e.g., timeouts or errors
      _other ->
        stream_next(hash)
    end
  end

  defp handle_chunk(hash, @done) do
    broadcast_complete(hash)
    @done
  end
  defp handle_chunk(hash, str) do
    text =
      Jason.decode!(str)
      |> Map.get("choices")
      |> Enum.map(fn choice ->
        choice
        |> Map.get("delta")
        |> Map.get("content")
      end)
      |> Enum.join("")

    broadcast_chunk(hash, text)

    text
  end

  defp setup_request_data(text_model, text, stream) do
    %{
      messages: [
        %{
          role: "user",
          content: text
        }
      ],
      model: text_model,
      temperature: 0.7,
      stream: stream
    }
    |> Jason.encode!()
  end

  # I'm wrapping this function to simplify the calling function for instructional purposes.
  defp do_post(url, request_data, openai_api_key) do
    opts = [recv_timeout: 30_000, timeout: 30_000]

    response_body =
      HTTPoison.post!(
        url,
        request_data,
        [
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer #{openai_api_key}"}
        ],
        opts
      )
      |> Map.get(:body)
      |> Jason.decode!()

    response_body
    |> Map.get("choices")
    |> hd()
    |> Map.get("message")
    |> Map.get("content")
  end
end
