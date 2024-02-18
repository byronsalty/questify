defmodule QuestifyWeb.QuestLiveTest do
  use QuestifyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Questify.GamesFixtures

  @create_attrs %{name: "some name", description: "some description", slug: "some slug"}
  @update_attrs %{name: "some updated name", description: "some updated description", slug: "some updated slug"}
  @invalid_attrs %{name: nil, description: nil, slug: nil}

  setup :register_and_log_in_user

  defp create_quest(_) do
    quest = quest_fixture()
    %{quest: quest}
  end

  describe "Index" do
    setup [:create_quest]

    test "lists all quests", %{conn: conn, quest: quest} do
      {:ok, _index_live, html} = live(conn, ~p"/quests")

      assert html =~ "Listing Quests"
      assert html =~ quest.name
    end

    test "saves new quest", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/quests")

      assert index_live |> element("a", "New Quest") |> render_click() =~
               "New Quest"

      assert_patch(index_live, ~p"/quests/new")

      assert index_live
             |> form("#quest-form", quest: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#quest-form", quest: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/quests")

      html = render(index_live)
      assert html =~ "Quest created successfully"
      assert html =~ "some name"
    end

    test "updates quest in listing", %{conn: conn, quest: quest} do
      {:ok, index_live, _html} = live(conn, ~p"/quests")

      assert index_live |> element("#quests-#{quest.id} a", "Edit") |> render_click() =~
               "Edit Quest"

      assert_patch(index_live, ~p"/quests/#{quest}/edit")

      assert index_live
             |> form("#quest-form", quest: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#quest-form", quest: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/quests")

      html = render(index_live)
      assert html =~ "Quest updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes quest in listing", %{conn: conn, quest: quest} do
      {:ok, index_live, _html} = live(conn, ~p"/quests")

      assert index_live |> element("#quests-#{quest.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#quests-#{quest.id}")
    end
  end

  describe "Show" do
    setup [:create_quest]

    test "displays quest", %{conn: conn, quest: quest} do
      {:ok, _show_live, html} = live(conn, ~p"/quests/#{quest}")

      assert html =~ "Show Quest"
      assert html =~ quest.name
    end

    test "updates quest within modal", %{conn: conn, quest: quest} do
      {:ok, show_live, _html} = live(conn, ~p"/quests/#{quest}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Quest"

      assert_patch(show_live, ~p"/quests/#{quest}/show/edit")

      assert show_live
             |> form("#quest-form", quest: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#quest-form", quest: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/quests/#{quest}")

      html = render(show_live)
      assert html =~ "Quest updated successfully"
      assert html =~ "some updated name"
    end
  end
end
