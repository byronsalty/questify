defmodule Instructor.Adapters.Ollama do
  @moduledoc """
  Adapter for Ollama's API. This uses Ollama's native API endpoints.
  """
  alias Instructor.JSONSchema
  alias Instructor.GBNF

  @behaviour Instructor.Adapter

  @doc """
  Run a completion against the Ollama server.
  """
  @impl true
  def chat_completion(params, _config \\ nil) do
    {response_model, _} = Keyword.pop!(params, :response_model)
    {messages, _} = Keyword.pop!(params, :messages)
    {model, _} = Keyword.pop!(params, :model)

    json_schema = JSONSchema.from_ecto_schema(response_model)
    grammar = GBNF.from_json_schema(json_schema)
    prompt = apply_chat_template(chat_template(), messages)
    stream = Keyword.get(params, :stream, false)

    if stream do
      do_streaming_chat_completion(prompt, grammar, model)
    else
      do_chat_completion(prompt, grammar, model)
    end
  end

  defp do_streaming_chat_completion(prompt, grammar, model) do
    pid = self()

    Stream.resource(
      fn ->
        Task.async(fn ->
          Req.post!(url(),
            json: %{
              model: model,
              prompt: prompt,
              format: "json",
              stream: true
            },
            receive_timeout: 60_000,
            into: fn {:data, data}, {req, resp} ->
              send(pid, data)
              {:cont, {req, resp}}
            end
          )

          send(pid, :done)
        end)
      end,
      fn acc ->
        receive do
          :done ->
            {:halt, acc}

          "data: " <> data ->
            data = Jason.decode!(data)
            {[data], acc}
        end
      end,
      fn acc -> acc end
    )
    |> Stream.map(fn %{"response" => chunk} ->
      to_openai_streaming_response(chunk)
    end)
  end

  defp to_openai_streaming_response(chunk) when is_binary(chunk) do
    %{
      "choices" => [
        %{"delta" => %{"tool_calls" => [%{"function" => %{"arguments" => chunk}}]}}
      ]
    }
  end

  defp do_chat_completion(prompt, grammar, model) do
    response =
      Req.post!(url(),
        json: %{
          model: model,
          prompt: prompt,
          format: "json",
          grammar: grammar,
          stream: false
        }
      )

    case response.body do
      %{"response" => response_json} ->
        {:ok, %{
          "choices" => [
            %{
              "message" => %{
                "tool_calls" => [
                  %{
                    "function" => %{
                      "arguments" => response_json
                    }
                  }
                ]
              }
            }
          ]
        }}
      _ ->
        {:error, "Invalid response from Ollama"}
    end
  end

  defp url do
    config = Application.get_env(:questify, :completions)
    "#{config[:ollama_url]}/api/generate"
  end

  defp chat_template do
    :mistral_instruct
  end

  defp apply_chat_template(:mistral_instruct, messages) do
    prompt =
      messages
      |> Enum.map_join("\n\n", fn
        %{role: "assistant", content: content} -> "#{content} </s>"
        %{content: content} -> "[INST] #{content} [/INST]"
      end)

    "<s>#{prompt}"
  end
end
