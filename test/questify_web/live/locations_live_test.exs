defmodule QuestifyWeb.LocationsLiveTest do
  use QuestifyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Questify.GamesFixtures

  @create_attrs %{name: "some name", description: "some description"}
  @update_attrs %{name: "some updated name", description: "some updated description"}
  @invalid_attrs %{name: nil, description: nil}

  defp create_locations(_) do
    locations = locations_fixture()
    %{locations: locations}
  end

  describe "Index" do
    setup [:create_locations]

    test "lists all locations", %{conn: conn, locations: locations} do
      {:ok, _index_live, html} = live(conn, ~p"/locations")

      assert html =~ "Listing Locations"
      assert html =~ locations.name
    end

    test "saves new locations", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/locations")

      assert index_live |> element("a", "New Locations") |> render_click() =~
               "New Locations"

      assert_patch(index_live, ~p"/locations/new")

      assert index_live
             |> form("#locations-form", locations: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#locations-form", locations: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/locations")

      html = render(index_live)
      assert html =~ "Locations created successfully"
      assert html =~ "some name"
    end

    test "updates locations in listing", %{conn: conn, locations: locations} do
      {:ok, index_live, _html} = live(conn, ~p"/locations")

      assert index_live |> element("#locations-#{locations.id} a", "Edit") |> render_click() =~
               "Edit Locations"

      assert_patch(index_live, ~p"/locations/#{locations}/edit")

      assert index_live
             |> form("#locations-form", locations: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#locations-form", locations: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/locations")

      html = render(index_live)
      assert html =~ "Locations updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes locations in listing", %{conn: conn, locations: locations} do
      {:ok, index_live, _html} = live(conn, ~p"/locations")

      assert index_live |> element("#locations-#{locations.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#locations-#{locations.id}")
    end
  end

  describe "Show" do
    setup [:create_locations]

    test "displays locations", %{conn: conn, locations: locations} do
      {:ok, _show_live, html} = live(conn, ~p"/locations/#{locations}")

      assert html =~ "Show Locations"
      assert html =~ locations.name
    end

    test "updates locations within modal", %{conn: conn, locations: locations} do
      {:ok, show_live, _html} = live(conn, ~p"/locations/#{locations}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Locations"

      assert_patch(show_live, ~p"/locations/#{locations}/show/edit")

      assert show_live
             |> form("#locations-form", locations: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#locations-form", locations: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/locations/#{locations}")

      html = render(show_live)
      assert html =~ "Locations updated successfully"
      assert html =~ "some updated name"
    end
  end
end
