defmodule Tev.PageController do
  use Tev.Web, :controller
  use Tev.Auth, authorize: false
  use Tev.Auth, :current_user

  alias Tev.PageView

  def index(conn, _params, nil) do
    render conn, "index.html", view: nil
  end
  def index(conn, params, user) do
    render conn, "index.html", view: PageView.new(params, user)
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
