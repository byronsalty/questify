defmodule Questify.AgentHandler do
  use GenServer

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def trailblaze(from_location, text) do
    # create a post request to the server

    generate_action(from_location, text)
  end

  @impl true
  def init(_) do
    {:ok, nil}
  end

  # @impl true
  # def handle_cast({:blaze, from_id, text}, _state) do
  #   openai_api_key = Application.get_env(:questify, :openai)[:openai_api_key]

  #   {:noreply, nil}
  # end

  def generate_action(from_location, text) do
    quest = from_location.quest

    [to_location | _] = Questify.Games.get_location_by_text(quest, text)

    {:ok, gen} =
      Instructor.chat_completion(
        model: "gpt-3.5-turbo",
        response_model: Questify.Games.ActionGen,
        max_retries: 2,
        messages: [
          %{
            role: "user",
            content: """
            Your purpose is to create a new action that moves a person from their current location
            to the new location that they are describing.

            Here is some information about the game world:
            ```
            #{quest.description}
            ```

            The user is moving from this location:
            ```
            #{from_location.name} #{from_location.description}
            ```

            to this location:
            ```
            #{to_location.name} #{to_location.description}
            ```

            This is how the user requested the action:
            ```
            #{text}
            ```
            """
          }
        ]
      )
      |> IO.inspect(label: "action generation")

    Questify.Games.create_action(%{
      "quest_id" => quest.id,
      "from_id" => from_location.id,
      "to_id" => to_location.id,
      "command" => gen.command,
      "description" => gen.description
    })
  end
end
