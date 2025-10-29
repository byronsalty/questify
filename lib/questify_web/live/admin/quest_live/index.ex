defmodule QuestifyWeb.QuestLive.Index do
  use QuestifyWeb, :live_view

  alias Questify.Games
  alias Questify.Games.Quest
  alias Questify.Accounts

  # Idle timeout: 30 minutes for admin pages
  @idle_timeout_ms 30 * 60 * 1000

  @impl true
  def mount(_params, session, socket) do
    socket = assign_current_user(socket, session)

    IO.inspect(socket.assigns.current_user, label: "current_user")

    quests = Games.list_quests_by_user(socket.assigns.current_user)

    # Start idle timeout timer
    schedule_idle_timeout()

    {:ok, stream(socket, :quests, quests)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Quest")
    |> assign(:quest, Games.get_quest!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Quest")
    |> assign(:quest, %Quest{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Quests")
    |> assign(:quest, nil)
  end

  @impl true
  def handle_info({QuestifyWeb.QuestLive.FormComponent, {:saved, quest}}, socket) do
    IO.inspect(quest, label: "saving")
    {:noreply, stream_insert(socket, :quests, quest)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    # Reset idle timeout on user interaction
    schedule_idle_timeout()

    quest = Games.get_quest!(id)
    {:ok, _} = Games.delete_quest(quest)

    {:noreply, stream_delete(socket, :quests, quest)}
  end

  # Handle idle timeout - redirect to home page
  @impl true
  def handle_info(:idle_timeout, socket) do
    {:noreply, push_navigate(socket, to: ~p"/")}
  end

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

  # Schedule the idle timeout timer
  defp schedule_idle_timeout do
    Process.send_after(self(), :idle_timeout, @idle_timeout_ms)
  end
end
