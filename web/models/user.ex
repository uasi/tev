defmodule Tev.User do
  use Tev.Web, :model

  alias Tev.AccessToken
  alias Tev.Repo

  schema "users" do
    field :twitter_id_str, :string
    field :twitter_screen_name, :string
    has_one :twitter_access_token, AccessToken

    timestamps
  end

  @required_fields ~w(
    twitter_id_str
  )
  @optional_fields ~w(
    twitter_screen_name
  )

  def find_or_create_by_twitter_id_str(id_str) do
    query = from u in __MODULE__,
      where: u.twitter_id_str == ^id_str,
      preload: [:twitter_access_token]
    Repo.one(query) || create_with_twitter_id_str(id_str)
  end
  defp create_with_twitter_id_str(id_str) do
    %__MODULE__{}
    |> __MODULE__.changeset(%{"twitter_id_str" => id_str})
    |> Repo.insert!
  end

  @doc """
  Inserts or updates `twitter_access_token` assoc with given credentials and (re)preloads it.

  Raises `Ecto.InvalidChangesetError` if `user` is not persisted.
  """
  @spec insert_or_update_twitter_access_token(User.t, %{}) :: User.t
  def insert_or_update_twitter_access_token(user, params = %{oauth_token: _, oauth_token_secret: _}) do
    user = Repo.preload(user, [:twitter_access_token])
    current_token = (user.twitter_access_token || build_assoc(user, :twitter_access_token))
    new_token =
      current_token
      |> AccessToken.changeset(params)
      |> Repo.insert_or_update!
    %{user | twitter_access_token: new_token}
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_assoc(:twitter_access_token)
    |> unique_constraint(:twitter_id_str)
  end
end
