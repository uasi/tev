defmodule Tev.SessionController do
  use Tev.Web, :controller

  alias Tev.TwitterAuth
  alias Tev.User

  @doc """
  GET /login
  """
  def login(conn, _params) do
    redirect conn, external: TwitterAuth.authenticate_url!
  end

  @doc """
  GET /login/callback
  """
  def login_callback(conn, %{"oauth_verifier" => verifier, "oauth_token" => token}) do
    user = authenticate_user(verifier, token)
    conn =
      conn
      |> put_session(:user_id, user.id)
      |> put_session(:twitter_id_str, user.twitter_id_str)
    redirect conn, to: "/"
  end
  defp authenticate_user(oauth_verifier, oauth_token) do
    raw_access_token =
      TwitterAuth.configure!(oauth_verifier, oauth_token)
      |> Map.take([:oauth_token, :oauth_token_secret])
    TwitterAuth.authenticated_user!.id_str
    |> User.find_or_create_by_twitter_id_str
    |> User.insert_or_update_twitter_access_token(raw_access_token)
  end
end
