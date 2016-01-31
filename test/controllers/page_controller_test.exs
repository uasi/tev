defmodule Tev.PageControllerTest do
  use Tev.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Log in"
  end
end
