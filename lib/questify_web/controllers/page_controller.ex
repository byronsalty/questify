defmodule QuestifyWeb.PageController do
  use QuestifyWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    quests = Questify.Games.list_quests()

    render(conn, :home, quests: quests, layout: false)
  end
  def start(conn, %{"id" => id}) do
    # The home page is often custom made,
    # so skip the default app layout.
    quest = Questify.Games.get_quest!(id)

    render(conn, :location, quest: quest, layout: false)
  end
end
