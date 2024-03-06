defmodule QuestifyWeb.PlayLive.Play do
  use QuestifyWeb, :live_view

  alias Questify.Games
  alias Questify.Repo

  @topic "generations"

  @impl true
  def mount(_params, _session, socket) do
    QuestifyWeb.Endpoint.subscribe(@topic)

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
     |> assign(:hash, nil)}
  end

  @impl true
  def handle_event("do_action", %{"command" => user_text}, socket) do
    # Do something with the value

    # action_options = Games.get_location_action_options(socket.assigns.location)
    location = socket.assigns.location

    chosen = Games.get_action_by_text(location, user_text)

    socket =
      if Enum.count(chosen) == 0 do
        action_output = "Try something else"
        to_id = location.id

        socket
        |> assign(:output_description, action_output)
        |> assign(:to_id, to_id)
        |> assign(:get_input, false)
      else
        chosen = hd(chosen)

        IO.inspect(chosen, label: "found an action")

        if chosen.from_id == nil do
          IO.puts("special action")
          do_special(socket, location, chosen, user_text)
        else
          socket
          |> assign(:output_description, chosen.description)
          |> assign(:to_id, chosen.to_id)
          |> assign(:get_input, false)
        end
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("continue", _, socket) do
    # Do something with the value

    Games.update_play(socket.assigns.play, %{rating: 1.0})

    handle_info({:move, socket.assigns.to_id}, socket)
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
    # IO.inspect(to_id, label: "sending experience to new location")

    Games.update_play(socket.assigns.play, %{location_id: to_id})

    {:noreply, push_patch(socket, to: ~p"/play/#{socket.assigns.play}")}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          topic: @topic,
          event: "text_update",
          payload: {:text_update, hash, text}
        },
        socket
      ) do
    IO.inspect({hash, text}, label: "text update received")

    if socket.assigns.hash == hash do
      updated_output = socket.assigns.output_description <> text

      {:noreply, assign(socket, :output_description, updated_output)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          topic: @topic,
          event: "text_complete",
          payload: {:text_complete, hash}
        },
        socket
      ) do
    if socket.assigns.hash == hash do
      {:noreply, assign(socket, :hash, nil)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          topic: @topic,
          event: event_type,
          payload: payload
        },
        socket
      ) do
    IO.inspect("event: #{event_type}, payload: #{payload}", label: "un handled broadcast")

    {:noreply, socket}
  end

  defp do_special(socket, location, action, text) do
    case action.description do
      "Replace with action" ->
        {:ok, action} = Questify.AgentHandler.generate_action(location, text)

        [action]

      "Replace with lore" ->
        # lore_string = Questify.Lore.get_related_lore(location, text)
        hash = :crypto.hash(:md5, text) |> Base.encode16(case: :lower)
        lore_prompt = Questify.Lore.generate_lore_prompt(location.quest, text)
        lore_string = "Yes... I can tell you about that...\n\n"

        Questify.TextHandler.stream_completion(hash, lore_prompt)

        socket
        |> assign(:hash, hash)
        |> assign(:output_description, lore_string)
        |> assign(:to_id, location.id)
        |> assign(:get_input, false)

      other ->
        IO.inspect(other, label: "unexpected special case")
    end
  end

  # defp send_move(chosen) do
  #   to_id = chosen.to_id
  #   description_delay = String.length(chosen.description) * 5

  #   pid = self()

  #   Task.start(fn ->
  #     # Wait half a second before adding the thinking to give a better UX
  #     Process.sleep(3000 + description_delay)
  #     send(pid, {:move, to_id})
  #   end)
  # end
end
