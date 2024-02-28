defmodule QuestifyWeb.LocationLive.Show do
  use QuestifyWeb, :live_view

  alias Questify.Games
  alias Questify.Repo

  @impl true
  def mount(_params, _session, socket) do
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

  defp page_title(:show), do: "Show Location"
  defp page_title(:edit), do: "Edit Location"
end
