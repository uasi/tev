defmodule Tev.PageView do
  defstruct [:user, :page]
  @type t :: %__MODULE__{}

  use Tev.Web, :view

  import Ecto, only: [assoc: 2]
  import Ecto.Query

  alias Tev.HomeTimelineTweet
  alias Tev.Repo
  alias Tev.Tweet
  alias Tev.User

  @spec new(%{}, User.t) :: t
  def new(params, user) do
    page =
      user
      |> assoc(:home_timeline)
      |> Repo.one!
      |> tweets_in_timeline
      |> limit(^Application.get_env(:tev, :max_timeline_tweets))
      |> Repo.paginate(params)
    %__MODULE__{user: user, page: page}
  end

  defp tweets_in_timeline(timeline) do
    from tt in HomeTimelineTweet,
      where: tt.home_timeline_id == ^timeline.id,
      order_by: [desc: tt.id],
      join: tw in assoc(tt, :tweet),
      select: tw
  end

  @spec tweets_to_photo_urls([Tweet.t]) :: [binary]
  defp tweets_to_photo_urls(tweets) do
    tweets
    |> Stream.map(&photo_urls_in_tweet/1)
    |> Stream.concat
    |> Enum.to_list
  end

  @spec photo_urls_in_tweet(%{}) :: Stream.t | []
  defp photo_urls_in_tweet(%{object: %{"extended_entities" => %{"media" => media}}}) do
    media
    |> Stream.filter(&(&1["type"] == "photo"))
    |> Stream.map(&(&1["media_url"]))
  end
  defp photo_urls_in_tweet(_) do
    []
  end
end
