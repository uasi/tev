defmodule Tev.User do
  use Tev.Web, :model

  alias Tev.AccessToken
  alias Tev.Repo
  alias Tev.Timeline
  alias Tev.Utils

  @primary_key {:id, :integer, autogenerate: false}

  schema "users" do
    field :screen_name, :string
    field :visited_at, Ecto.DateTime
    has_one :access_token, AccessToken
    has_many :timelines, Timeline

    timestamps
  end

  @type t :: %__MODULE__{}

  @required_fields ~w(
    screen_name
  )
  @optional_fields ~w(
    visited_at
  )

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
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
  Inserts home and like timelines unless exist.
  """
  @spec ensure_timelines_exist(t) :: t
  def ensure_timelines_exist(user) do
    Timeline.ensure_exists(user.id, :home)
    Timeline.ensure_exists(user.id, :like)
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

  @doc """
  Returns true if the user is admin, false otherwise.
  """
  @spec admin?(t) :: boolean
  def admin?(user) do
    Integer.to_string(user.id) in admin_id_strings
  end

  defp admin_id_strings do
    (System.get_env("ADMIN_ID") || "")
    |> String.split(",", trim: true)
  end

  def update_visited_at!(user, opts \\ []) do
    loose = Keyword.get(opts, :loose, false)
    t = user.visited_at
    unless loose && t && Utils.elapsed_since_datetime(t, :mins) < 1 do
      user
      |> changeset(%{visited_at: Ecto.DateTime.utc})
      |> Repo.update!
    end
  end

  defimpl Tev.L.Gist do
    def gist(user) do
      "user=#{user.id}@#{user.screen_name}"
    end
  end
end
