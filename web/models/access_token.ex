defmodule Tev.AccessToken do
  use Tev.Web, :model

  alias Tev.Crypto
  alias Tev.User

  schema "access_tokens" do
    field :oauth_token, :string, virtual: true
    field :oauth_token_encrypted, :binary
    field :oauth_token_secret, :string, virtual: true
    field :oauth_token_secret_encrypted, :binary
    belongs_to :user, User

    timestamps
  end

  @required_fields ~w(oauth_token_encrypted oauth_token_secret_encrypted user_id)
  @optional_fields ~w()
  @encryptable_fields ~w(oauth_token oauth_token_secret)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    params = encrypt_params(params)
    model
    |> cast(params, @required_fields, @optional_fields)
    |> assoc_constraint(:user)
    |> unique_constraint(:user_id)
  end

  def decrypt(model) do
    decrypted = for field <- @encryptable_fields, into: %{} do
      value = Map.get(model, :"#{field}_encrypted")
      {:"#{field}", Crypto.decrypt(value)}
    end
    Map.merge(model, decrypted)
  end

  defp encrypt_params(params) when params == :empty or params == %{}, do: params
  defp encrypt_params(params) do
    to_key = if is_binary(hd(Map.keys(params))), do: &(&1), else: &String.to_atom/1
    encryptable_fields = Enum.map(@encryptable_fields, to_key)
    encrypted_params =
      params
      |> Map.take(encryptable_fields)
      |> Enum.map(fn({field, value}) ->
        {to_key.("#{field}_encrypted"), Crypto.encrypt(value)}
      end)
      |> Enum.into(%{})
    Map.merge(params, encrypted_params)
  end
end
