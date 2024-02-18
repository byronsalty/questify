defmodule QuestifyWeb.PlayLive.Show do
  use QuestifyWeb, :live_view

  alias Questify.Games
  alias Questify.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket, layout: false}
  end

  @impl true
  def handle_params(%{"id" => location_id}, _, socket) do
    location = Games.get_location!(location_id) |> Repo.preload([:actions, :quest])

    action_options =
      location.actions
      |> Enum.with_index(fn action, ind -> {ind + 1, action.command, action.id} end)

    action_description =
      action_options
      |> Enum.map(fn {ind, command, _id} -> "(#{ind}) #{command}. " end)
      |> Enum.join("\n ")

    {output_description, get_input, game_over} =
      if location.is_terminal == true do
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
     |> assign(:name, location.name)
     |> assign(:img_url, img_url)
     |> assign(:description, location.description)
     |> assign(:action_options, action_options)
     |> assign(:action_description, action_description)
     |> assign(:output_description, output_description)
     |> assign(:get_input, get_input)
     |> assign(:game_over, game_over)
    }
  end

  @impl true
  def handle_event("do_action", %{"command" => value}, socket) do
    # Do something with the value

    chosen = socket.assigns.action_options
      |> Enum.filter(fn {ind, _, id} -> "#{ind}" == value end)
      |> Enum.map(fn {_, _, id} -> Games.get_action!(id) end)

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
  def handle_info({:move, to_id}, socket) do

    IO.inspect(to_id, label: "sending experience to new location")

    {:noreply, push_patch(socket, to: ~p"/play/#{to_id}")}
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
