defmodule QuestifyWeb.PageController do
  use QuestifyWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    quests = Questify.Games.list_quests()

    render(conn, :home, quests: quests, layout: false)
  end
  def view(conn, %{"slug" => slug}) do
    IO.inspect(slug, label: "slug")
    quest = Questify.Games.get_quest_by_slug!(slug)


    render(conn, :view, quest: quest, layout: false)
  end
  def start(conn, %{"slug" => slug}) do
    IO.inspect(slug, label: "slug")
    quest = Questify.Games.get_quest_by_slug!(slug)

    IO.inspect(quest, label: "quest")

    start_locs = quest.locations |> Enum.filter(fn loc -> loc.is_starting == true end)

    if Enum.count(start_locs) > 0 do
      start = hd(start_locs)
      redirect(conn, to: ~p"/play/#{start.id}")
    else
      raise("No starting location for Quest")
    end
  end
end
