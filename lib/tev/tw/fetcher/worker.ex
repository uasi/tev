defmodule Tev.Tw.Fetcher.Worker do
  @moduledoc false

  use GenServer

  require Logger

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
    Logger.debug("#{__MODULE__} #{inspect self}: started")
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

    user_id = user.id
    since_id = timeline.max_tweet_id
    Logger.info("#{__MODULE__} #{inspect self}: fetching tweets; user_id=#{user_id} timeline_id=#{timeline.id}(#{timeline.type}) since_id=#{since_id}")
    TickTock.tick
    result = fetch_all_tweets(timeline)
    elapsed = TickTock.tock

    case result do
      {:ok, tweets} ->
        Logger.info("#{__MODULE__} #{inspect self}: fetched tweets; n=#{length tweets} elapsed=#{elapsed}ms")
        if length(tweets) > 0 do
          Collector.collect(timeline, tweets)
        end
      {:error, e} ->
        Logger.warn("#{__MODULE__} #{inspect self}: failed to fetch tweets; error=#{inspect e} elapsed=#{elapsed}ms")
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
