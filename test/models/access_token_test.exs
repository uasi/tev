defmodule Tev.AccessTokenTest do
  use Tev.ModelCase

  alias Tev.AccessToken
  alias Tev.User

  test "encrypt and decrypt" do
    %{id: user_id} = Repo.insert!(%User{})
    attrs = %{oauth_token: "TOKEN", oauth_token_secret: "TOKEN_SECRET", user_id: user_id}
    %{id: id} =
      %AccessToken{}
      |> AccessToken.changeset(attrs)
      |> Repo.insert!
    access_token =
      AccessToken
      |> Repo.get(id)
      |> AccessToken.decrypt

    assert access_token.oauth_token == attrs[:oauth_token]
    assert access_token.oauth_token_secret == attrs[:oauth_token_secret]
  end
end
