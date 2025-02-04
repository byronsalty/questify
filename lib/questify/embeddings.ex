defmodule Questify.Embeddings do
  def embed(text, opts \\ []) when is_binary(text) do
    config = Application.get_env(:questify, :embeddings)
    provider = Keyword.get(opts, :provider, config[:provider])

    case provider do
      :ollama -> embed_ollama(text, config)
      :openai -> embed_openai(text, config)
      _ -> {:error, :invalid_provider}
    end
    |> IO.inspect(label: "embed response")
  end

  def embed!(text, opts \\ []) when is_binary(text) do
    {:ok, %{embedding: embedding}} = embed(text, opts)
    embedding
  end

  defp embed_ollama(text, config) do
    # Add a small delay to prevent server overload
    Process.sleep(50)

    response =
      HTTPoison.post(
        "#{config[:ollama_url]}/api/embeddings",
        Jason.encode!(%{
          model: config[:ollama_model],
          prompt: text
        }),
        [
          {"Content-Type", "application/json"}
        ]
      )

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok,
         %{
           text: text,
           embedding: Jason.decode!(body) |> Map.get("embedding")
         }}

      {:ok, %HTTPoison.Response{status_code: _status_code}} ->
        {:error, :bad_request}

      {:error, error} ->
        case error do
          %HTTPoison.Error{reason: :checkout_timeout, id: nil} ->
            {:error, :checkout_timeout}

          _ ->
            {:error, error}
        end
    end
  end

  defp embed_openai(text, config) do
    response =
      HTTPoison.post(
        config[:openai_url],
        Jason.encode!(%{
          input: text,
          model: config[:openai_model]
        }),
        [
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer #{config[:openai_api_key]}"}
        ]
      )

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok,
         %{
           text: text,
           embedding:
             body
             |> Jason.decode!()
             |> Map.get("data")
             |> List.first()
             |> Map.get("embedding")
         }}

      {:ok, %HTTPoison.Response{status_code: _status_code}} ->
        {:error, :bad_request}

      {:error, error} ->
        case error do
          %HTTPoison.Error{reason: :checkout_timeout, id: nil} ->
            {:error, :checkout_timeout}

          _ ->
            {:error, error}
        end
    end
  end
end
