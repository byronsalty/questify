defmodule QuestifyWeb.PageControllerTest do
  use QuestifyWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "questify.webp"
  end
end
