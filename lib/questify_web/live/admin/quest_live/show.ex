defmodule QuestifyWeb.QuestLive.Show do
  use QuestifyWeb, :live_view

  alias Questify.Games
  alias Questify.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    quest = Games.get_quest!(id) |> Repo.preload([:locations])
    locations = quest.locations

    IO.inspect(locations, label: "locations on show")

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:quest, quest)
     |> assign(:locations, quest.locations)}
  end

  defp page_title(:show), do: "Show Quest"
  defp page_title(:edit), do: "Edit Quest"
end
