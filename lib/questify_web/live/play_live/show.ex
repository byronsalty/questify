defmodule QuestifyWeb.PlayLive.Show do
  use QuestifyWeb, :live_view

  alias Questify.Games
  alias Questify.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket, layout: false}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    play = Games.get_play!(id)
    location = Games.get_location!(play.location_id) |> Repo.preload([:actions, :quest])

    action_hint = Games.get_location_action_hint(location)

    {output_description, get_input, game_over} =
      if location.is_terminal == true do
        Games.update_play(play, %{is_complete: true})

        {"Game Over", false, true}
      else
        {nil, true, false}
      end

    img_url =
      if is_nil(location.img_url) do
        "https://d8g32g7q3zoxw.cloudfront.net/mystery.png"
      else
        location.img_url
      end

    {:noreply,
     socket
     |> assign(:play, play)
     |> assign(:voted, false)
     |> assign(:location, location)
     |> assign(:name, location.name)
     |> assign(:img_url, img_url)
     |> assign(:description, location.description)
     |> assign(:action_description, action_hint)
     |> assign(:output_description, output_description)
     |> assign(:get_input, get_input)
     |> assign(:game_over, game_over)
    }
  end

  @impl true
  def handle_event("do_action", %{"command" => value}, socket) do
    # Do something with the value

    # action_options = Games.get_location_action_options(socket.assigns.location)
    location = socket.assigns.location

    chosen = Games.get_action_by_text(location, value)

    action_output =
      if Enum.count(chosen) > 0 do
        chosen = hd(chosen)

        send_move(chosen.to_id)

        chosen.description
      else
        "Try something else"
      end

    {:noreply,
     socket
     |> assign(:output_description, action_output)
     |> assign(:get_input, false)
    }
  end

  @impl true
  def handle_event("up_vote", _, socket) do
    # Do something with the value

    Games.update_play(socket.assigns.play, %{rating: 1.0})

    {:noreply, assign(socket, :voted, true)}
  end

  @impl true
  def handle_event("down_vote", _, socket) do
    # Do something with the value

    Games.update_play(socket.assigns.play, %{rating: 0.0})

    {:noreply, assign(socket, :voted, true)}
  end


  @impl true
  def handle_info({:move, to_id}, socket) do

    IO.inspect(to_id, label: "sending experience to new location")

    Games.update_play(socket.assigns.play, %{location_id: to_id})

    {:noreply, push_patch(socket, to: ~p"/play/#{socket.assigns.play}")}
  end


  defp send_move(to_id) do
    pid = self()

    Task.start(fn ->
      # Wait half a second before adding the thinking to give a better UX
      Process.sleep(3000)
      send(pid, {:move, to_id})
    end)
  end
end
