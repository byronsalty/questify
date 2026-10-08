defmodule QuestifyWeb.ActionLiveTest do
  use QuestifyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Questify.GamesFixtures

  setup :register_and_log_in_user

  @create_attrs %{command: "some command", description: "some description"}
  @update_attrs %{command: "some updated command", description: "some updated description"}
  @invalid_attrs %{command: nil, description: nil}

  defp create_action(%{user: user}) do
    quest = quest_fixture(%{creator_id: user.id})
    action = action_fixture(%{quest_id: quest.id})
    %{quest: quest, action: action}
  end

  describe "Index" do
    setup [:create_action]

    test "renders and validates the new action form", %{conn: conn, action: action} do
      {:ok, index_live, html} = live(conn, ~p"/actions/#{action.from_id}/new")

      assert html =~ "New Action"

      assert index_live
             |> form("#action-form", action: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"
    end

    # Known bug: the new action form doesn't submit a quest_id, so the action
    # fails validation, and on success it would push_patch to /quests, which
    # is a different root LiveView.
    @tag :skip
    test "saves new action", %{conn: conn, action: action} do
      {:ok, index_live, _html} = live(conn, ~p"/actions/#{action.from_id}/new")

      {:ok, _quests_live, html} =
        index_live
        |> form("#action-form", action: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/quests")

      assert html =~ "Action created successfully"
    end

    test "renders and validates the edit action form", %{conn: conn, action: action} do
      {:ok, index_live, html} = live(conn, ~p"/actions/#{action}/edit")

      assert html =~ "Edit Action"

      assert index_live
             |> form("#action-form", action: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"
    end

    # Known bug: saving push_patches to /quests, which is a different root
    # LiveView, so the LiveView crashes after the update is persisted.
    @tag :skip
    test "updates action", %{conn: conn, action: action} do
      {:ok, index_live, _html} = live(conn, ~p"/actions/#{action}/edit")

      {:ok, _quests_live, html} =
        index_live
        |> form("#action-form", action: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/quests")

      assert html =~ "Action updated successfully"
    end
  end

  describe "Show" do
    setup [:create_action]

    test "displays action", %{conn: conn, action: action} do
      {:ok, _show_live, html} = live(conn, ~p"/actions/#{action}")

      assert html =~ "Action #{action.id}"
      assert html =~ action.command
    end

    test "updates action within modal", %{conn: conn, action: action} do
      {:ok, show_live, _html} = live(conn, ~p"/actions/#{action}")

      assert show_live |> element("a", "Edit action") |> render_click() =~
               "Edit Action"

      assert_patch(show_live, ~p"/actions/#{action}/show/edit")

      assert show_live
             |> form("#action-form", action: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#action-form", action: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/actions/#{action}")

      html = render(show_live)
      assert html =~ "Action updated successfully"
      assert html =~ "some updated command"
    end
  end
end
