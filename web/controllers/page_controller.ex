defmodule Tev.PageController do
  use Tev.Web, :controller

  def index(conn, _params) do
    id_str = get_session(conn, :twitter_id_str)
    render conn, "index.html", id_str: id_str
  end
end
