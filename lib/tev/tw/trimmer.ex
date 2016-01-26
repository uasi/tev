defmodule Tev.Tw.Trimmer do
  @moduledoc """
  Trims timeline.
  """

  require Logger

  import Ecto.Query

  alias Tev.HomeTimeline
  alias Tev.HomeTimelineTweet
  alias Tev.Repo
  alias Tev.Timeline

  @max_tweets Application.get_env(:tev, :max_timeline_tweets)

  @spec trim_all(integer) :: :ok
  def trim_all(max_tweets \\ @max_tweets) do
    timelines =
      overflowed_timelines(max_tweets)
      |> Repo.all
    Logger.info("#{__MODULE__}: trimming timelines; n=#{length timelines} limit=#{max_tweets}")
    t = :erlang.monotonic_time(:milli_seconds)
    timelines
    |> Enum.map(&trim(&1, max_tweets))
    elapsed = :erlang.monotonic_time(:milli_seconds) - t
    Logger.info("#{__MODULE__}: trimmed timelines; elapsed=#{elapsed}ms")
    :ok
  end

  @spec trim(Timeline.t, integer) :: integer
  def trim(timeline, max_tweets \\ @max_tweets) do
    Logger.info("#{__MODULE__}: trimming timeline; id=#{timeline.id} limit=#{max_tweets}")
    {:ok, {deleted, _}} =
      Repo.transaction fn ->
        overflowed_timeline_tweets(timeline, max_tweets)
        |> Repo.delete_all
      end
    Logger.info("#{__MODULE__}: trimmed timeline; deleted_tweets=#{deleted}")
    deleted
  end

  defp overflowed_timelines(max_tweets) do
    from t in HomeTimeline,
      join: tt in assoc(t, :home_timeline_tweets),
      group_by: t.id,
      having: count(tt.id) > ^max_tweets,
      select: t
  end

  defp overflowed_timeline_tweets(timeline, max_tweets) do
    # Keep in mind that `Repo.delete_all` allows only `where` and `join`
    # expressions in query.
    id =
      from(tt in HomeTimelineTweet,
        where: tt.home_timeline_id == ^timeline.id,
        order_by: [desc: :id],
        offset: ^max(max_tweets - 1, 0),
        limit: 1,
        select: tt.id)
      |> Repo.one
    from tt in HomeTimelineTweet,
      where: tt.home_timeline_id == ^timeline.id and tt.id < ^id
  end
end
