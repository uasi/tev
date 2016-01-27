defmodule Tev.PageController do
  use Tev.Web, :controller
  use Tev.Auth, authorize: false
  use Tev.Auth, :current_user

  alias Tev.PageView
  alias Tev.User

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
    if User.admin?(user) do
      if User.can_fetch?(user) do
        Tev.Tw.Dispatcher.dispatch(user)
        text conn, "ok"
      else
        raise_forbidden
      end
    else
      raise_unauthorized
    end
  end
end
