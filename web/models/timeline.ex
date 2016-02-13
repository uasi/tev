defmodule Tev.Timeline do
  use Tev.Web, :model
  use Tev.EctoType.Tag

  alias Tev.Repo
  alias Tev.TimelineTweet
  alias Tev.User

  deftag Type, [home: 1, like: 2]

  schema "timelines" do
    field :type, Type
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

  @spec ensure_exists(integer, Type.t) :: t | no_return
  def ensure_exists(user_id, type) do
    query = from t in __MODULE__,
      where: t.user_id == ^user_id and t.type == ^type
    Repo.one(query) || insert(user_id, type)
  end

  @spec ensure_exists(integer, Type.t) :: t | no_return
  defp insert(user_id, type) do
    %__MODULE__{}
    |> changeset(%{user_id: user_id, type: type})
    |> Repo.insert!
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

  def recently_collected?(_timeline = %{collected_at: nil}) do
    false
  end
  def recently_collected?(timeline) do
    elapsed_min =
      timeline.collected_at
      |> Ecto.DateTime.to_erl
      |> Timex.Date.from
      |> Timex.Date.to_timestamp
      |> Timex.Time.elapsed(:mins)
    case timeline.type do
      :home ->
        elapsed_min < 1
      _ ->
        elapsed_min < 15
    end
  end

  defimpl Tev.L.Gist do
    def gist(timeline) do
      "timeline=#{timeline.type}:#{timeline.id}"
    end
  end
end
