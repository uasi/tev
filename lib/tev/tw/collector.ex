defmodule Tev.Tw.Collector do
  @moduledoc """
  Collector receives tweets from fetcher workers and stores photo tweets.
  """

  use GenServer
  use Tev.L

  alias Tev.Repo
  alias Tev.Timeline
  alias Tev.TimelineTweet
  alias Tev.Tweet

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    L.debug("started")
    {:ok, nil}
  end

  @spec collect(Timeline.t, [ExTwitter.Model.Tweet.t]) :: term
  def collect(timeline, tweets) do
    GenServer.cast(__MODULE__, {:collect, timeline, tweets})
  end

  def handle_cast({:collect, timeline, tweets}, _state) do
    do_collect(timeline, tweets)
    {:noreply, nil}
  end

  # For testing
  def handle_call({:collect, timeline, tweets}, _from, _state) do
    do_collect(timeline, tweets)
    {:reply, :ok, nil}
  end

  defp do_collect(timeline, []) do
    L.info("no tweets collected", [timeline])
    Timeline.update_collected_at!(timeline)
  end
  defp do_collect(timeline, tweets) do
    Repo.transaction fn ->
      if max_id_changed?(timeline) do
        L.info("discarding fetched tweets (timeline has changed)", [timeline, n: length(tweets)])
      else
        max_id = List.first(tweets).id
        tweets
        |> Enum.filter(&photo_tweet?/1)
        |> insert_tweets(timeline, max_id)
        Timeline.update_collected_at!(timeline)
      end
    end
  end

  def max_id_changed?(timeline) do
    Repo.reload(timeline).max_tweet_id != timeline.max_tweet_id
  end

  defp photo_tweet?(%{extended_entities: %{media: media = [_|_]}}) do
    Enum.any?(media, &(&1[:type] == "photo"))
  end
  defp photo_tweet?(_tweet) do
    false
  end

  defp insert_tweets(tweets, timeline, max_id) do
    L.info("inserting tweets", [timeline, n: length(tweets)])
    Repo.transaction fn ->
      for tweet <- tweets do
        unless Repo.get(Tweet, tweet.id, log: false) do
          tweet_object = Map.delete(tweet, :__struct__)
          %Tweet{id: tweet.id, object: tweet_object}
          |> Tweet.changeset(%{})
          |> Repo.insert!
        end

        %TimelineTweet{timeline_id: timeline.id, tweet_id: tweet.id}
        |> TimelineTweet.changeset(%{})
        |> Repo.insert!
      end

      timeline
      |> Timeline.changeset(%{max_tweet_id: max_id})
      |> Repo.update!
      L.info("set max id", [timeline, max_id: max_id])
    end
    L.info("inserted tweets", [timeline, n: length(tweets)])
  end
end
