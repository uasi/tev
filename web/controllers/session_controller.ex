defmodule Tev.SessionController do
  use Tev.Web, :controller

  alias Tev.TwitterAuth

  # GET /login
  #
  def login(conn, _params) do
    redirect conn, external: TwitterAuth.authenticate_url!
  end

  # GET /login/callback
  #
  def login_callback(conn, %{"oauth_token" => token, "oauth_verifier" => verifier}) do
    TwitterAuth.configure!(verifier, token)
    id_str = TwitterAuth.authenticated_user!.id_str
    conn = put_session(conn, :twitter_id_str, id_str)
    redirect conn, to: "/"
  end
end
