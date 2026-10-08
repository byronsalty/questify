defmodule Questify.InstructorStub do
  @moduledoc """
  Test `Instructor.Adapter` that answers chat completions with canned,
  valid data for the app's response models instead of calling OpenAI.
  """

  @behaviour Instructor.Adapter

  @impl true
  def chat_completion(params, _config) do
    args = params |> Keyword.get(:response_model) |> canned_response() |> Jason.encode!()

    {:ok,
     %{
       "choices" => [
         %{
           "message" => %{
             "role" => "assistant",
             "content" => args,
             "tool_calls" => [%{"function" => %{"name" => "Schema", "arguments" => args}}]
           }
         }
       ]
     }}
  end

  defp canned_response(Questify.Creator.LocationGen) do
    %{
      name: "Stubbed Location",
      description:
        "A quiet stubbed clearing generated in the test environment, far from any network."
    }
  end

  defp canned_response(Questify.Creator.ActionGen) do
    %{command: "walk along the path", description: "You walk along the stubbed path."}
  end

  defp canned_response(Questify.Lore.RumorGen) do
    %{trigger: "ask about the stub", description: "They say nothing here ever leaves the test."}
  end

  defp canned_response(_), do: %{}
end
