defmodule QuestifyWeb.LocationLive.Show do
  use QuestifyWeb, :live_view

  alias Questify.Games
  alias Questify.Repo

  @topic "generations"
  # Idle timeout: 30 minutes for admin pages (admins may be referencing while working)
  @idle_timeout_ms 30 * 60 * 1000

  @impl true
  def mount(_params, _session, socket) do
    QuestifyWeb.Endpoint.subscribe(@topic)

    # Start idle timeout timer - will redirect to home if no activity
    schedule_idle_timeout()

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
