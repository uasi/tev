defmodule Tev.Timeline do
  use Tev.Web, :model
  use Tev.EctoType.Tag

  alias Tev.Repo
  alias Tev.TimelineTweet
  alias Tev.User

  deftag TypeTag, [home: 1]

  schema "timelines" do
    field :type, TypeTag
    field :max_tweet_id, :integer
    field :fetch_started_at, Ecto.DateTime
    field :collected_at, Ecto.DateTime

    belongs_to :user, User

    has_many :timeline_tweets, TimelineTweet
    has_many :tweets, through: [:timeline_tweets, :tweet]

    timestamps
  end

  @type t :: %__MODULE__{}

  @required_fields ~w(
    type
    user_id
  )
  @optional_fields ~w(
    max_tweet_id
    fetch_started_at
    collected_at
  )

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> assoc_constraint(:user)
    |> unique_constraint(:user_id)
  end

  def get_or_insert_by_user_id(user_id) do
    query = from t in __MODULE__,
      where: t.user_id == ^user_id
    Repo.one(query) || insert(user_id)
  end

  defp insert(user_id, type \\ :home) do
    %__MODULE__{}
    |> changeset(%{user_id: user_id, type: type})
    |> Repo.insert!
  end

  def ensure_exists(user_id, type) do
    query = from t in __MODULE__,
      where: t.user_id == ^user_id
    Repo.one(query) || insert(user_id, type)
  end

  def update_fetch_started_at!(timeline) do
    timeline
    |> changeset(%{fetch_started_at: Ecto.DateTime.utc})
    |> Repo.update!
  end

  def update_collected_at!(timeline) do
    timeline
    |> changeset(%{collected_at: Ecto.DateTime.utc})
    |> Repo.update!
  end
end
