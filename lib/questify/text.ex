defmodule Questify.Text do

  def get_completion(text) do
    text_model = "gpt-3.5-turbo"
    openai_api_key = Application.get_env(:questify, :openai)[:openai_api_key]
    openai_completion_url = "https://api.openai.com/v1/chat/completions"

    data =
      %{
        messages: [
          %{
            role: "user",
            content: text
          }
        ],
        model: text_model,
        temperature: 0.7
      }
      |> Jason.encode!()

    IO.inspect(data, label: "request data")

    opts = [recv_timeout: 30_000, timeout: 30_000]

    response_body =
      HTTPoison.post!(
        openai_completion_url,
        data,
        [
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer #{openai_api_key}"}
        ],
        opts
      )
      |> IO.inspect(label: "request_body")
      |> Map.get(:body)
      |> Jason.decode!()

    response_body
    |> IO.inspect(label: "response_body")
    |> Map.get("choices")
    |> hd()
    |> Map.get("message")
    |> Map.get("content")
  end
end
