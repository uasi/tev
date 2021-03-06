defmodule Tev.PageView do
  defstruct [:user, :timeline, :page]
  @type t :: %__MODULE__{}

  use Tev.Web, :view

  import Ecto.Query

  alias Tev.Repo
  alias Tev.Timeline
  alias Tev.TimelineTweet
  alias Tev.Tweet
  alias Tev.User

  @type tweet_props :: %{id: binary, url: binary, photo_url: binary}

  @spec new(%{}, User.t, Timeline.Type.t) :: t
  def new(params, user, timeline_type) do
    user = Repo.preload(user, :timelines)
    timeline = Enum.find(user.timelines, &(&1.type == timeline_type))
    page =
      timeline
      |> tweets_in_timeline
      |> limit(^Application.get_env(:tev, :max_timeline_tweets))
      |> Repo.paginate(params)
    %__MODULE__{user: user, timeline: timeline, page: page}
  end

  defp tweets_in_timeline(timeline) do
    from tt in TimelineTweet,
      where: tt.timeline_id == ^timeline.id,
      order_by: [desc: tt.id],
      join: tw in assoc(tt, :tweet),
      select: tw
  end

  @spec tweet_props_stream([Tweet.t]) :: [tweet_props]
  defp tweet_props_stream(tweets) do
    tweets
    |> Stream.map(&tweet_props/1)
    |> Stream.concat
  end

  @spec tweet_props(Tweet.t) :: Stream.t | []
  defp tweet_props(%{id: id, object: %{"extended_entities" => %{"media" => media}}}) do
    photo_media_to_tweet_props = fn media ->
      %{
        id: id,
        url: media["expanded_url"],
        photo_url: media["media_url_https"],
      }
    end
    media
    |> Stream.filter(&(&1["type"] == "photo"))
    |> Stream.map(photo_media_to_tweet_props)
  end

  @spec pagination_paths(Plug.Conn.t, t) :: %{first: term, prev: term, next: term, last: term}
  defp pagination_paths(conn, _view = %{page: page}) do
    index = path_to(conn, :page, :index)
    first = if page.page_number > 1, do: index
    prev = if page.page_number > 1, do: index <> "?page=#{page.page_number - 1}"
    next = if page.page_number < page.total_pages, do: index <> "?page=#{page.page_number + 1}"
    last = if page.page_number < page.total_pages, do: index <> "?page=#{page.total_pages}"
    %{first: first, prev: prev, next: next, last: last}
  end

  @spec next_page_number(term) :: integer | nil
  def next_page_number(page) do
    if page.page_number < page.total_pages do
      page.page_number + 1
    else
      nil
    end
  end

  @spec collected?(t) :: boolean
  defp collected?(_view = %{timeline: timeline}) do
    timeline.collected_at != nil
  end

  @spec has_entries?(t) :: boolean
  defp has_entries?(_view = %{page: %{total_entries: total}}) do
    total > 0
  end
end
