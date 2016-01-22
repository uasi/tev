defmodule Tev.PageController do
  use Tev.Web, :controller
  use Tev.Auth, authorize: false
  use Tev.Auth, :current_user

  def index(conn, _params, user) do
    user_id = if user, do: user.id, else: nil
    render conn, "index.html", user_id: user_id
  end

  @authorize true
  def confidential(conn, _params, _user) do
    text conn, "ok"
  end

  @authorize true
  def fetch(conn, _params, user) do
    Tev.Tw.Dispatcher.dispatch(user)
    text conn, "ok"
  end
end
