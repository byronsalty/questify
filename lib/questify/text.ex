defmodule Questify.Text do

  def get_completion(text) do
    text_model = "gpt-3.5-turbo"
    openai_api_key = Application.get_env(:questify, :openai)[:openai_api_key]
    openai_completion_url = "https://api.openai.com/v1/chat/completions"

    # Setup the request data
    request_data = setup_request_data(text_model, text)

    # Make the request, get the response
    do_post(openai_completion_url, request_data, openai_api_key)
  end

  defp setup_request_data(text_model, text) do
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
  end

  @doc """
  I'm wrapping this function to simplify the calling function for instructional purposes.
  """
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
