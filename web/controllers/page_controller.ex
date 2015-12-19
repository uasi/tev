defmodule Tev.PageController do
  use Tev.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
