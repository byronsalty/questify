defmodule Questify.Completions do
  @moduledoc """
  Handles text completions using either Ollama or OpenAI.
  """

  @doc """
  Gets a completion from the configured provider.
  """
  def get_completion(prompt, opts \\ []) do
    case Application.get_env(:questify, :completions)[:provider] do
      :ollama -> get_ollama_completion(prompt, opts)
      _ -> get_openai_completion(prompt, opts)
    end
  end

  @doc """
  Gets a streaming completion from the configured provider.
  """
  def stream_completion(prompt, callback, opts \\ []) do
    case Application.get_env(:questify, :completions)[:provider] do
      :ollama -> stream_ollama_completion(prompt, callback, opts)
      _ -> stream_openai_completion(prompt, callback, opts)
    end
  end

  defp get_ollama_completion(prompt, _opts) do
    config = Application.get_env(:questify, :completions)
    url = "#{config[:ollama_url]}/api/generate"
    model = config[:ollama_model]

    body = Jason.encode!(%{
      model: model,
      prompt: prompt,
      stream: false
    })

    headers = [{"Content-Type", "application/json"}]

    case HTTPoison.post(url, body, headers) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"response" => response}} -> {:ok, response}
          _ -> {:error, "Invalid response format"}
        end
      {:ok, %{status_code: status}} ->
        {:error, "HTTP #{status}"}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp stream_ollama_completion(prompt, callback, _opts) do
    config = Application.get_env(:questify, :completions)
    url = "#{config[:ollama_url]}/api/generate"
    model = config[:ollama_model]

    body = Jason.encode!(%{
      model: model,
      prompt: prompt,
      stream: true
    })

    headers = [{"Content-Type", "application/json"}]
    opts = [recv_timeout: 30_000, timeout: 30_000, stream_to: self()]

    case HTTPoison.post!(url, body, headers, opts) do
      %HTTPoison.AsyncResponse{id: _id} ->
        stream_next_chunk(callback)
        :ok
      _ ->
        {:error, "Failed to start streaming"}
    end
  end

  defp stream_next_chunk(callback) do
    receive do
      %HTTPoison.AsyncChunk{chunk: chunk} ->
        case Jason.decode(chunk) do
          {:ok, %{"response" => response}} ->
            callback.(response)
            stream_next_chunk(callback)
          _ -> 
            stream_next_chunk(callback)
        end
      %HTTPoison.AsyncEnd{} ->
        :done
      _ ->
        stream_next_chunk(callback)
    end
  end

  defp get_openai_completion(prompt, _opts) do
    case Instructor.chat_completion(
      model: "gpt-3.5-turbo",
      messages: [%{role: "user", content: prompt}]
    ) do
      {:ok, response} -> {:ok, response.message.content}
      error -> error
    end
  end

  defp stream_openai_completion(prompt, callback, _opts) do
    case Instructor.chat_completion(
      model: "gpt-3.5-turbo",
      messages: [%{role: "user", content: prompt}],
      stream: true
    ) do
      {:ok, stream} ->
        Enum.each(stream, fn chunk ->
          callback.(chunk.choices |> List.first() |> Map.get(:delta) |> Map.get(:content))
        end)
        :ok
      error -> error
    end
  end
end
