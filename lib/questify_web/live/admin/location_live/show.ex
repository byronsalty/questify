defmodule QuestifyWeb.LocationLive.Show do
  use QuestifyWeb, :live_view

  alias Questify.Games
  alias Questify.Repo

  @topic "generations"

  @impl true
  def mount(_params, _session, socket) do
    QuestifyWeb.Endpoint.subscribe(@topic)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    location =
      Games.get_location!(id)
      |> Repo.preload([:actions, :quest])

    {:noreply,
     socket
     |> assign(:quest, location.quest)
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:location, location)}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          topic: @topic,
          event: "image_complete",
          payload: _
        },
        socket
      ) do
    location =
      Games.get_location!(socket.assigns.location.id)
      |> Repo.preload([:actions, :quest])

    {:noreply, assign(socket, :location, location)}
  end

  defp page_title(:show), do: "Show Location"
  defp page_title(:edit), do: "Edit Location"
end
