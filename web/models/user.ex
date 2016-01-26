defmodule Tev.User do
  use Tev.Web, :model

  alias Tev.AccessToken
  alias Tev.HomeTimeline
  alias Tev.Repo

  @primary_key {:id, :integer, autogenerate: false}

  schema "users" do
    field :screen_name, :string
    field :last_fetch_started_at, Ecto.DateTime
    has_one :access_token, AccessToken
    has_one :home_timeline, HomeTimeline

    timestamps
  end

  @type t :: %__MODULE__{}

  @required_fields ~w(
    screen_name
  )
  @optional_fields ~w(
    last_fetch_started_at
  )

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_assoc(:access_token)
  end

  @spec from_user_object(ExTwitter.Model.User.t) :: t
  def from_user_object(user) do
    query = from u in __MODULE__,
      where: u.id == ^user.id,
      preload: [:access_token]
    Repo.one(query) || insert(user)
  end

  defp insert(user) do
    %__MODULE__{id: user.id, screen_name: user.screen_name}
    |> Repo.insert!
  end

  @doc """
  Inserts home timeline unless exists.
  """
  @spec ensure_timeline_exists(t) :: t
  def ensure_timeline_exists(user) do
    HomeTimeline.get_or_insert_by_user_id(user.id)
    user
  end

  @doc """
  Inserts or updates `access_token` assoc with given credentials and (re)preloads it.

  Raises `Ecto.InvalidChangesetError` if `user` is not persisted.
  """
  @spec insert_or_update_access_token(t, %{}) :: t
  def insert_or_update_access_token(user, params = %{oauth_token: _, oauth_token_secret: _}) do
    user = Repo.preload(user, [:access_token])
    current_token = (user.access_token || build_assoc(user, :access_token))
    new_token =
      current_token
      |> AccessToken.changeset(params)
      |> Repo.insert_or_update!
    %{user | access_token: new_token}
  end
end
