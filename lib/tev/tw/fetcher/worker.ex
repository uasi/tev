defmodule Tev.Tw.Fetcher.Worker do
  @moduledoc false

  use GenServer
  use Tev.L

  alias Tev.AccessToken
  alias Tev.Repo
  alias Tev.TickTock
  alias Tev.Timeline
  alias Tev.Tw.Collector
  alias Tev.Tw.Fetcher.WorkerTable
  alias Tev.Tw.TimelineStream

  def start_link([]) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    L.debug("started")
    {:ok, nil}
  end

  def run(pid, user, timeline) do
    GenServer.call(pid, {:run, user, timeline})
  end

  def handle_call({:run, user, timeline}, _from, _state) do
    try do
      WorkerTable.check_in(timeline.id)
      do_run(user, timeline)
    after
      WorkerTable.check_out(timeline.id)
    end
    {:reply, :ok, nil}
  end

  defp do_run(user, timeline) do
    user
    |> Repo.preload(:access_token)
    |> Map.get(:access_token)
    |> AccessToken.configure_twitter_client

    Timeline.update_fetch_started_at!(timeline)

    L.info("fetching tweets", [user, timeline, since_id: timeline.max_tweet_id])
    TickTock.tick
    result = fetch_all_tweets(timeline)
    elapsed = TickTock.tock

    case result do
      {:ok, tweets} ->
        L.info("fetched tweets", [n: length(tweets), elapsed: "#{elapsed}ms"])
        Collector.collect(timeline, tweets)
      {:error, e} ->
        L.warn("failed to fetch tweets", [error: e, elapsed: "#{elapsed}ms"])
    end
  end

  defp fetch_all_tweets(timeline) do
    try do
      tweets =
        TimelineStream.timeline(timeline.type, since_id: timeline.max_tweet_id)
        |> Enum.to_list
      {:ok, tweets}
    rescue
      e -> {:error, e}
    end
  end
end
