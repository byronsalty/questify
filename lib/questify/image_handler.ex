defmodule Questify.ImageHandler do
  use GenServer

  alias ExAws.S3

  @topic "generations"

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def generate_image(hash, filename, prompt) do
    # create a post request to the server
    IO.inspect(prompt, label: "starting generation for prompt")

    GenServer.cast(__MODULE__, {:generate_image, hash, filename, prompt})
  end

  @impl true
  def init(_) do
    {:ok, nil}
  end

  @impl true
  def handle_cast({:generate_image, hash, file_name, prompt}, _state) do
    openai_api_key = Application.get_env(:questify, :openai)[:openai_api_key]
    endpoint = Application.get_env(:questify, :openai)[:image_gen_url]

    IO.inspect(prompt, label: "request to generate received")

    opts = [async: true, recv_timeout: 30_000, timeout: 30_000]

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{openai_api_key}"}
    ]

    data =
      Jason.encode!(%{
        "model" => "dall-e-3",
        "size" => "1024x1024",
        "quality" => "standard",
        "n" => 1,
        "prompt" => prompt
      })

    response =
      HTTPoison.post!(
        endpoint,
        data,
        headers,
        opts
      )

    IO.inspect(response, label: "response")

    response_body =
      response
      |> Map.get(:body)
      |> Jason.decode!()

    image_url = response_body |> get_in(["data", Access.at(0), "url"])

    IO.inspect(image_url, label: "openai image_url")

    {:ok, file_response} = HTTPoison.get(image_url)

    write_file_to_s3(file_name, file_response.body, "image/png")
    |> IO.inspect(label: "write_file_to_s3")

    # TODO: broadcast that file is ready on s3
    broadcast_complete(hash)

    {:noreply, nil}
  end

  def create_img_url(hash) do
    file_name = "#{hash}.png"
    url = "https://d8g32g7q3zoxw.cloudfront.net/#{file_name}"

    {url, file_name}
  end

  def broadcast_complete(hash) do
    Phoenix.PubSub.broadcast!(Questify.PubSub, @topic, %Phoenix.Socket.Broadcast{
      topic: @topic,
      event: "image_complete",
      payload: {:image_complete, hash}
    })
  end

  def test_gen() do
    echo = Questify.Games.get_quest_by_slug!("echo")

    Questify.Games.create_location(%{
      "name" => "Echo Ridge Tavern",
      "description" => """
      You arrive at the Echo Ridge Tavern. People sit in the dark shadows drinking alone or watch others as they gamble with dice. Alcohol flows readily, as do tips for the beer maidens.
      """,
      "is_terminal" => false,
      "is_starting" => false,
      "quest_id" => echo.id
    })
  end

  defp write_file_to_s3(unique_path, file_binary, content_type) do
    bucket_name = "quest-publish"

    IO.inspect("Writing file to S3: #{unique_path}")

    doc =
      S3.put_object(
        bucket_name,
        unique_path,
        file_binary,
        content_type: content_type
      )
      |> ExAws.request()

    {doc, bucket_name}
  end
end
