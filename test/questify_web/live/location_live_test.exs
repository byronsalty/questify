defmodule QuestifyWeb.LocationLiveTest do
  use QuestifyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Questify.GamesFixtures
  import Questify.CreatorFixtures

  @create_attrs %{name: "some name", description: "some description"}
  @update_attrs %{name: "some updated name", description: "some updated description"}
  @invalid_attrs %{name: nil, description: nil}

  setup :register_and_log_in_user

  # Locations are managed from a quest the logged-in user created. The quest
  # needs a theme because new locations are generated from it (via the
  # Instructor stub in test).
  defp create_location(%{user: user}) do
    quest = quest_fixture(%{creator_id: user.id, theme_id: theme_fixture().id})
    location = location_fixture(%{quest_id: quest.id})
    %{quest: quest, location: location}
  end

  describe "Index" do
    setup [:create_location]

    test "saves new location", %{conn: conn, quest: quest} do
      {:ok, index_live, html} = live(conn, ~p"/locations/#{quest.id}/new")

      assert html =~ "New Location"

      assert index_live
             |> form("#location-form", location: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _quest_live, html} =
        index_live
        |> form("#location-form", location: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/quests/#{quest.id}")

      assert html =~ "Location created successfully"
      # Name and description are replaced by the generated (stubbed) values.
      assert html =~ "Stubbed Location"
    end

    test "updates location", %{conn: conn, quest: quest, location: location} do
      {:ok, index_live, html} = live(conn, ~p"/locations/#{location}/edit")

      assert html =~ "Edit Location"

      assert index_live
             |> form("#location-form", location: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _quest_live, html} =
        index_live
        |> form("#location-form", location: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/quests/#{quest.id}")

      assert html =~ "Location updated successfully"
      assert html =~ "some updated name"
    end
  end

  describe "Show" do
    setup [:create_location]

    test "displays location", %{conn: conn, location: location} do
      {:ok, _show_live, html} = live(conn, ~p"/locations/#{location}")

      assert html =~ "Location #{location.id}"
      assert html =~ location.name
    end

    test "updates location within modal", %{conn: conn, location: location} do
      {:ok, show_live, _html} = live(conn, ~p"/locations/#{location}")

      assert show_live |> element("a", "Edit location") |> render_click() =~
               "Edit Location"

      assert_patch(show_live, ~p"/locations/#{location}/show/edit")

      assert show_live
             |> form("#location-form", location: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _show_live, html} =
        show_live
        |> form("#location-form", location: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/locations/#{location}")

      assert html =~ "Location updated successfully"
      assert html =~ "some updated name"
    end
  end
end
