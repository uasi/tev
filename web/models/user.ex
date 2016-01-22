defmodule Tev.User do
  use Tev.Web, :model

  alias Tev.AccessToken
  alias Tev.Repo

  @primary_key {:id, :integer, autogenerate: false}

  schema "users" do
    field :screen_name, :string
    has_one :twitter_access_token, AccessToken

    timestamps
  end

  @type t :: %__MODULE__{}

  @required_fields ~w(
    screen_name
  )
  @optional_fields ~w(
  )

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_assoc(:twitter_access_token)
  end

  @spec from_user_object(ExTwitter.Model.User.t) :: t
  def from_user_object(user) do
    query = from u in __MODULE__,
      where: u.id == ^user.id,
      preload: [:twitter_access_token]
    Repo.one(query) || insert(user)
  end

  defp insert(user) do
    %__MODULE__{id: user.id, screen_name: user.screen_name}
    |> Repo.insert!
  end

  @doc """
  Inserts or updates `twitter_access_token` assoc with given credentials and (re)preloads it.

  Raises `Ecto.InvalidChangesetError` if `user` is not persisted.
  """
  @spec insert_or_update_twitter_access_token(t, %{}) :: t
  def insert_or_update_twitter_access_token(user, params = %{oauth_token: _, oauth_token_secret: _}) do
    user = Repo.preload(user, [:twitter_access_token])
    current_token = (user.twitter_access_token || build_assoc(user, :twitter_access_token))
    new_token =
      current_token
      |> AccessToken.changeset(params)
      |> Repo.insert_or_update!
    %{user | twitter_access_token: new_token}
  end
end
