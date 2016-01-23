defmodule Tev.Tw.Fetcher.Worker do
  @moduledoc false

  use GenServer

  require Logger

  alias Tev.AccessToken
  alias Tev.Repo
  alias Tev.Tw.Collector
  alias Tev.Tw.TimelineStream

  def start_link([]) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    Logger.debug("#{__MODULE__} #{inspect self}: started")
    {:ok, nil}
  end

  def run(pid, user, timeline) do
    GenServer.cast(pid, {:run, user, timeline})
  end

  def handle_cast({:run, user, timeline}, _state) do
    user
    |> Repo.preload(:access_token)
    |> Map.get(:access_token)
    |> AccessToken.configure_twitter_client

    user_id = user.id
    since_id = timeline.max_tweet_id
    Logger.info("#{__MODULE__} #{inspect self}: fetching tweets; user_id=#{user_id} since_id=#{since_id}")
    t = :erlang.monotonic_time(:milli_seconds)
    result = fetch_all_tweets(user_id, since_id)
    elapsed = :erlang.monotonic_time(:milli_seconds) - t

    case result do
      {:ok, []} ->
        Logger.info("#{__MODULE__} #{inspect self}: fetched tweets; user_id=#{user_id} since_id=#{since_id} elapsed=#{elapsed}ms")
      {:ok, tweets} ->
        Logger.info("#{__MODULE__} #{inspect self}: fetched tweets; user_id=#{user_id} since_id=#{since_id} elapsed=#{elapsed}ms")
        Collector.collect(timeline, tweets)
      {:error, e} ->
        Logger.warn("#{__MODULE__} #{inspect self}: failed to fetch tweets; error=#{inspect e} elapsed=#{elapsed}ms")
    end

    {:noreply, nil}
  end

  defp fetch_all_tweets(user_id, since_id) do
    try do
      tweets =
        TimelineStream.home_timeline(user_id, since_id: since_id)
        |> Enum.to_list
      {:ok, tweets}
    rescue
      e -> {:error, e}
    end
  end
end
