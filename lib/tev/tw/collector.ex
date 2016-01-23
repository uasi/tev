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

  def handle_cast({:collect, _timeline, []}, _state) do
    Logger.info("#{__MODULE__} #{inspect self}: no tweets, do nothing")
  end
  def handle_cast({:collect, timeline, tweets}, _state) do
    max_id = List.first(tweets).id
    tweets
    |> Enum.filter(&photo_tweet?/1)
    |> insert_tweets(timeline, max_id)
    {:noreply, nil}
  end

  defp photo_tweet?(%{extended_entities: %{media: media = [_|_]}}) do
    Enum.any?(media, &(&1[:type] == "photo"))
  end
  defp photo_tweet?(_tweet) do
    false
  end

  defp insert_tweets(tweets, timeline, max_id) do
    Logger.info("#{__MODULE__} #{inspect self}: inserting tweets; num_tweets=#{length tweets}")
    Repo.transaction fn ->
      for tweet <- tweets, Repo.get(Tweet, tweet.id, log: false) == nil do
        tweet_object = Map.delete(tweet, :__struct__)
        %Tweet{id: tweet.id, object: tweet_object}
        |> Tweet.changeset(%{})
        |> Repo.insert!

        %HomeTimelineTweet{home_timeline_id: timeline.id, tweet_id: tweet.id}
        |> HomeTimelineTweet.changeset(%{})
        |> Repo.insert!
      end

      timeline
      |> HomeTimeline.changeset(%{max_tweet_id: max_id})
      |> Repo.update!
    end
    Logger.info("#{__MODULE__} #{inspect self}: inserted tweets; num_tweets=#{length tweets}")
  end
end
