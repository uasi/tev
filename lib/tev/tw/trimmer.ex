defmodule Tev.Tw.Trimmer do
  @moduledoc """
  Trims timeline.
  """

  use Tev.L

  import Ecto.Query

  alias Tev.Repo
  alias Tev.TickTock
  alias Tev.Timeline
  alias Tev.TimelineTweet

  @max_tweets Application.get_env(:tev, :max_timeline_tweets)

  @spec trim_all(integer) :: :ok
  def trim_all(max_tweets \\ @max_tweets) do
    timelines =
      overflowed_timelines(max_tweets)
      |> Repo.all
    L.info("trimming timelines", [n: length(timelines), limit: max_tweets])
    TickTock.tick
    timelines
    |> Enum.map(&trim(&1, max_tweets))
    L.info("trimmed timelines", [elapsed: "#{TickTock.tock}ms"])
    :ok
  end

  @spec trim(Timeline.t, integer) :: integer
  def trim(timeline, max_tweets \\ @max_tweets) do
    L.info("trimming timeline", [timeline, limit: max_tweets])
    {:ok, {deleted, _}} =
      Repo.transaction fn ->
        overflowed_timeline_tweets(timeline, max_tweets)
        |> Repo.delete_all
      end
    L.info("trimmed timeline", [timeline, deleted_tweets: deleted])
    deleted
  end

  defp overflowed_timelines(max_tweets) do
    from t in Timeline,
      join: tt in assoc(t, :timeline_tweets),
      group_by: t.id,
      having: count(tt.id) > ^max_tweets,
      select: t
  end

  defp overflowed_timeline_tweets(timeline, max_tweets) do
    # Keep in mind that `Repo.delete_all` allows only `where` and `join`
    # expressions in query.
    id =
      from(tt in TimelineTweet,
        where: tt.timeline_id == ^timeline.id,
        order_by: [desc: :id],
        offset: ^max(max_tweets - 1, 0),
        limit: 1,
        select: tt.id)
      |> Repo.one
    from tt in TimelineTweet,
      where: tt.timeline_id == ^timeline.id and tt.id < ^id
  end
end
