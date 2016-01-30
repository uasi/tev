defmodule Tev.PageView do
  defstruct [:user, :page]
  @type t :: %__MODULE__{}

  use Tev.Web, :view

  import Ecto.Query

  alias Tev.HomeTimeline
  alias Tev.HomeTimelineTweet
  alias Tev.Repo
  alias Tev.Tweet
  alias Tev.User

  @spec new(%{}, User.t) :: t
  def new(params, user) do
    page =
      HomeTimeline.get_or_insert_by_user_id(user.id)
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

  @spec pagination_paths(Plug.Conn.t, t) :: %{first: term, prev: term, next: term, last: term}
  defp pagination_paths(conn, _view = %{page: page}) do
    index = page_path(conn, :index)
    first = if page.page_number > 1, do: index
    prev = if page.page_number > 1, do: index <> "?page=#{page.page_number - 1}"
    next = if page.page_number < page.total_pages, do: index <> "?page=#{page.page_number + 1}"
    last = if page.page_number < page.total_pages, do: index <> "?page=#{page.total_pages}"
    %{first: first, prev: prev, next: next, last: last}
  end
end
