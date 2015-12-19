defmodule Tev.TwitterAuth do
  alias Tev.Endpoint
  alias Tev.Env

  @spec initialize :: :ok
  def initialize do
    ExTwitter.configure(
      consumer_key: Env.twitter_api_key!,
      consumer_secret: Env.twitter_api_secret!,
    )
  end

  @spec configure!(String.t, String.t) :: :ok
  def configure!(oauth_verifier, oauth_token) do
    {:ok, access_token} = ExTwitter.access_token(oauth_verifier, oauth_token)
    ExTwitter.configure(
      :process,
      consumer_key: Env.twitter_api_key!,
      consumer_secret: Env.twitter_api_secret!,
      access_token: access_token.oauth_token,
      access_token_secret: access_token.oauth_token_secret,
    )
  end

  @spec authenticate_url! :: String.t
  def authenticate_url! do
    token = ExTwitter.request_token(redirect_url)
    {:ok, authenticate_url} = ExTwitter.authenticate_url(token.oauth_token)
    authenticate_url
  end

  @spec authenticated_user! :: ExTwitter.Model.User.t
  def authenticated_user! do
    ExTwitter.verify_credentials
  end

  @spec redirect_url :: String.t
  defp redirect_url do
    "#{Endpoint.url}/login/callback"
  end
end
