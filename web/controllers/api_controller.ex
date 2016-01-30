defmodule Tev.ApiController do
  use Tev.Web, :controller
  use Tev.Auth, authorize: true
  use Tev.Auth, :current_user

  alias Tev.ApiView

  def rendered_tweets(conn, params, user) do
    json conn, ApiView.rendered_tweets(conn, params, user)
  end
end
