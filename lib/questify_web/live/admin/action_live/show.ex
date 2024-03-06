defmodule QuestifyWeb.ActionLive.Show do
  use QuestifyWeb, :live_view

  alias Questify.Games
  alias Questify.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    action = Games.get_action!(id) |> Repo.preload([:from])

    quest = Games.get_quest!(action.quest_id) |> Repo.preload(:locations)
    locations = quest.locations |> Enum.map(&{&1.name, &1.id})

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:action, action)
     |> assign(:from_id, action.from_id)
     |> assign(:locations, locations)}
  end

  defp page_title(:show), do: "Show Action"
  defp page_title(:edit), do: "Edit Action"
end
