defmodule QuestifyWeb.ActionLiveTest do
  use QuestifyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Questify.GamesFixtures


  setup :register_and_log_in_user

  @create_attrs %{command: "some command", description: "some description", is_terminal: true}
  @update_attrs %{command: "some updated command", description: "some updated description", is_terminal: false}
  @invalid_attrs %{command: nil, description: nil, is_terminal: false}

  defp create_action(_) do
    action = action_fixture()
    %{action: action}
  end

  describe "Index" do
    setup [:create_action]

    test "saves new action", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/actions")

      assert index_live |> element("a", "New Action") |> render_click() =~
               "New Action"

      assert_patch(index_live, ~p"/actions/new")

      assert index_live
             |> form("#action-form", action: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#action-form", action: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/actions")

      html = render(index_live)
      assert html =~ "Action created successfully"
      assert html =~ "some command"
    end

    test "updates action in listing", %{conn: conn, action: action} do
      {:ok, index_live, _html} = live(conn, ~p"/actions")

      assert index_live |> element("#actions-#{action.id} a", "Edit") |> render_click() =~
               "Edit Action"

      assert_patch(index_live, ~p"/actions/#{action}/edit")

      assert index_live
             |> form("#action-form", action: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#action-form", action: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/actions")

      html = render(index_live)
      assert html =~ "Action updated successfully"
      assert html =~ "some updated command"
    end

    test "deletes action in listing", %{conn: conn, action: action} do
      {:ok, index_live, _html} = live(conn, ~p"/actions")

      assert index_live |> element("#actions-#{action.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#actions-#{action.id}")
    end
  end

  describe "Show" do
    setup [:create_action]

    test "displays action", %{conn: conn, action: action} do
      {:ok, _show_live, html} = live(conn, ~p"/actions/#{action}")

      assert html =~ "Show Action"
      assert html =~ action.command
    end

    test "updates action within modal", %{conn: conn, action: action} do
      {:ok, show_live, _html} = live(conn, ~p"/actions/#{action}")

      assert show_live |> element("a", "Edit") |> render_click() =~
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
