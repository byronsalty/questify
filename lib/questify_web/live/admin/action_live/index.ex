defmodule QuestifyWeb.ActionLive.Index do
  alias Ecto.Repo
  use QuestifyWeb, :live_view

  alias Questify.Games
  alias Questify.Games.Action

  # Idle timeout: 30 minutes for admin pages
  @idle_timeout_ms 30 * 60 * 1000

  @impl true
  def mount(_params, _session, socket) do
    # Start idle timeout timer
    schedule_idle_timeout()

    {:ok, stream(socket, :actions, Games.list_actions())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    action = Games.get_action!(id)
    quest = Games.get_quest!(action.quest_id) |> Repo.preload(:locations)
    locations = quest.locations |> Enum.map(&{&1.name, &1.id})

    socket
    |> assign(:from_id, action.from_id)
    |> assign(:page_title, "Edit Action")
    |> assign(:action, action)
    |> assign(:locations, locations)
  end

  defp apply_action(socket, :new, %{"location_id" => from_id}) do
    from = Games.get_location!(from_id)

    quest = Games.get_quest!(from.quest_id) |> Repo.preload(:locations)
    locations = quest.locations |> Enum.map(&{&1.name, &1.id})

    socket
    |> assign(:from_id, from_id)
    |> assign(:page_title, "New Action")
    |> assign(:action, %Action{})
    |> assign(:locations, locations)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Actions")
    |> assign(:action, nil)
  end

  @impl true
  def handle_info({QuestifyWeb.ActionLive.FormComponent, {:saved, action}}, socket) do
    {:noreply, stream_insert(socket, :actions, action)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    # Reset idle timeout on user interaction
    schedule_idle_timeout()

    action = Games.get_action!(id)
    {:ok, _} = Games.delete_action(action)

    {:noreply, stream_delete(socket, :actions, action)}
  end

  # Handle idle timeout - redirect to home page
  @impl true
  def handle_info(:idle_timeout, socket) do
    {:noreply, push_navigate(socket, to: ~p"/")}
  end

  # Schedule the idle timeout timer
  defp schedule_idle_timeout do
    Process.send_after(self(), :idle_timeout, @idle_timeout_ms)
  end
end
