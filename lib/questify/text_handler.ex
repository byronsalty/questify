defmodule Questify.TextHandler do
  use GenServer

  @topic "generations"
  @done "[DONE]"

  alias Questify.Completions

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, nil}
  end

  def get_completion(text) do
    case Completions.get_completion(text) do
      {:ok, response} -> response
      {:error, reason} -> 
        IO.inspect(reason, label: "Completion error")
        "Error generating completion: #{inspect(reason)}"
    end
  end

  def stream_completion(hash, text) do
    Completions.stream_completion(
      text,
      fn chunk ->
        if chunk, do: broadcast_chunk(hash, chunk)
      end
    )
    broadcast_complete(hash)
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
end
