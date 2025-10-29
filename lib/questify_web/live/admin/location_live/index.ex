defmodule QuestifyWeb.LocationLive.Index do
  use QuestifyWeb, :live_view

  alias Questify.Games
  alias Questify.Games.Location

  # Idle timeout: 30 minutes for admin pages
  @idle_timeout_ms 30 * 60 * 1000

  @impl true
  def mount(_params, _session, socket) do
    # {:ok, stream(socket, :locations, Games.list_locations())}
    # Start idle timeout timer
    schedule_idle_timeout()

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    location = Games.get_location!(id)
    quest = Questify.Games.get_quest!(location.quest_id)

    socket
    |> assign(:quest, quest)
    |> assign(:page_title, "Edit Location")
    |> assign(:location, Games.get_location!(id))
  end

  defp apply_action(socket, :new, %{"quest_id" => quest_id}) do
    quest = Questify.Games.get_quest!(quest_id)

    socket
    |> assign(:quest, quest)
    |> assign(:page_title, "New Location")
    |> assign(:location, %Location{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Locations")
    |> assign(:location, nil)
  end

  @impl true
  def handle_info({QuestifyWeb.LocationLive.FormComponent, {:saved, location}}, socket) do
    {:noreply, stream_insert(socket, :locations, location)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    # Reset idle timeout on user interaction
    schedule_idle_timeout()

    location = Games.get_location!(id)
    {:ok, _} = Games.delete_location(location)

    {:noreply, stream_delete(socket, :locations, location)}
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
