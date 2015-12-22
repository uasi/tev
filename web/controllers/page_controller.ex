defmodule Tev.PageController do
  use Tev.Web, :controller
  use Tev.Auth, :current_user

  plug :authorize when action in [:confidential]

  def index(conn, _params, user) do
    id_str = if user, do: user.twitter_id_str, else: nil
    render conn, "index.html", id_str: id_str
  end

  def confidential(conn, _params, _user) do
    text conn, "ok"
  end
end
