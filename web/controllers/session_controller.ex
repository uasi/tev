defmodule Tev.SessionController do
  use Tev.Web, :controller

  alias Tev.Session
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
    conn
    |> Session.sign_in(user)
    |> redirect(to: "/")
  end

  defp authenticate_user(oauth_verifier, oauth_token) do
    raw_access_token =
      TwitterAuth.configure!(oauth_verifier, oauth_token)
      |> Map.take([:oauth_token, :oauth_token_secret])
    TwitterAuth.authenticated_user!
    |> User.from_user_object
    |> User.insert_or_update_twitter_access_token(raw_access_token)
  end

  @doc """
  GET /logout
  """
  def logout(conn, _params) do
    conn
    |> Session.sign_out
    |> redirect(to: "/")
  end
end
