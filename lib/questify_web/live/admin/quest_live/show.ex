defmodule QuestifyWeb.QuestLive.Show do
  use QuestifyWeb, :live_view

  alias Questify.Games
  alias Questify.Repo
  alias Questify.Accounts

  @impl true
  def mount(_params, session, socket) do
    socket = assign_current_user(socket, session)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    quest = Games.get_quest!(id) |> Repo.preload([:locations])

    if quest.creator_id != socket.assigns.current_user.id do
      {:noreply,
       socket
       |> put_flash(:error, "You are not the creator of this quest")
       |> push_patch(to: ~p"/quests")}
    else
      {:noreply,
       socket
       |> assign(:page_title, page_title(socket.assigns.live_action))
       |> assign(:quest, quest)
       |> assign(:locations, quest.locations)}
    end
  end

  defp page_title(:show), do: "Show Quest"
  defp page_title(:edit), do: "Edit Quest"

  defp assign_current_user(socket, session) do
    case session do
      %{"user_token" => user_token} ->
        assign_new(socket, :current_user, fn ->
          Accounts.get_user_by_session_token(user_token)
        end)

      %{} ->
        assign_new(socket, :current_user, fn -> nil end)
    end
  end
end
