defmodule Tev.Tw.Collector do
  @moduledoc """
  Collector receives tweets from fetcher workers and stores photo tweets.
  """

  use GenServer

  require Logger

  alias Tev.Repo
  alias Tev.HomeTimeline
  alias Tev.HomeTimelineTweet
  alias Tev.Tweet

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    Logger.debug("#{__MODULE__} #{inspect self}: started")
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
    Logger.info("#{__MODULE__} #{inspect self}: no tweets, do nothing; timeline_id=#{timeline.id}")
  end
  defp do_collect(timeline, tweets) do
    Repo.transaction fn ->
      if max_id_changed?(timeline) do
        Logger.info("#{__MODULE__} #{inspect self}: timeline has changed since fetch requested; discarding fetched tweets; timeline_id=#{timeline.id}")
      else
        max_id = List.first(tweets).id
        tweets
        |> Enum.filter(&photo_tweet?/1)
        |> insert_tweets(timeline, max_id)
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
    Logger.info("#{__MODULE__} #{inspect self}: inserting tweets; n=#{length tweets} timeline_id=#{timeline.id}")
    Repo.transaction fn ->
      for tweet <- tweets do
        unless Repo.get(Tweet, tweet.id, log: false) do
          tweet_object = Map.delete(tweet, :__struct__)
          %Tweet{id: tweet.id, object: tweet_object}
          |> Tweet.changeset(%{})
          |> Repo.insert!
        end

        %HomeTimelineTweet{home_timeline_id: timeline.id, tweet_id: tweet.id}
        |> HomeTimelineTweet.changeset(%{})
        |> Repo.insert!
      end

      timeline
      |> HomeTimeline.changeset(%{max_tweet_id: max_id})
      |> Repo.update!
      Logger.info("#{__MODULE__} #{inspect self}: set max id; id=#{max_id} timeline_id=#{timeline.id}")
    end
    Logger.info("#{__MODULE__} #{inspect self}: inserted tweets; n=#{length tweets} timeline_id=#{timeline.id}")
  end
end
