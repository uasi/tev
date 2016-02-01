defmodule Tev.TimelineTweet do
  use Tev.Web, :model

  alias Tev.Timeline
  alias Tev.Tweet

  schema "timeline_tweets" do
    belongs_to :timeline, Timeline
    belongs_to :tweet, Tweet

    timestamps
  end

  @required_fields ~w(
    timeline_id
    tweet_id
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
    |> assoc_constraint(:timeline)
    |> assoc_constraint(:tweet)
  end
end
