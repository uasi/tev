defmodule Tev.HomeTimeline do
  use Tev.Web, :model

  alias Tev.HomeTimelineTweet
  alias Tev.Repo
  alias Tev.User

  schema "home_timelines" do
    field :max_tweet_id, :integer
    field :fetch_started_at, Ecto.DateTime
    field :collected_at, Ecto.DateTime

    belongs_to :user, User

    has_many :home_timeline_tweets, HomeTimelineTweet
    has_many :tweets, through: [:home_timeline_tweets, :tweet]

    timestamps
  end

  @type t :: %__MODULE__{}

  @required_fields ~w(
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

  defp insert(user_id) do
    %__MODULE__{}
    |> changeset(%{user_id: user_id})
    |> Repo.insert!
  end
end
