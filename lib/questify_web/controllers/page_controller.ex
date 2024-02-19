defmodule QuestifyWeb.PageController do
  use QuestifyWeb, :controller

  alias Questify.Games

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    quests = Games.list_quests()

    render(conn, :home, quests: quests, layout: false)
  end
  def view(conn, %{"slug" => slug}) do
    IO.inspect(slug, label: "slug")
    quest = Games.get_quest_by_slug!(slug)


    render(conn, :view, quest: quest, layout: false)
  end
  def start(conn, %{"slug" => slug}) do
    IO.inspect(slug, label: "slug")
    quest = Games.get_quest_by_slug!(slug)

    IO.inspect(quest, label: "quest")

    start_locs = quest.locations |> Enum.filter(fn loc -> loc.is_starting == true end)

    if Enum.count(start_locs) > 0 do
      start = hd(start_locs)

      {:ok, new_play} = Games.create_play(%{quest_id: quest.id, location_id: start.id, is_complete: false})

      redirect(conn, to: ~p"/play/#{new_play}")
    else
      raise("No starting location for Quest")
    end
  end
end
