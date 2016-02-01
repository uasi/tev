defmodule Tev.Tw.CollectorTest do
  use ExUnit.Case, async: true

  import Ecto.Query, only: [from: 2]
  import Tev.Factory

  alias Tev.TimelineTweet
  alias Tev.Repo
  alias Tev.Tw.Collector
  alias Tev.Tweet

  defp count_inserted(tweets) do
    ids = Enum.map(tweets, &Map.get(&1, :id))
    from(t in Tweet,
      select: count(t.id),
      where: t.id in ^ids)
    |> Repo.one
  end

  test "collector inserts photo tweets" do
    normal_tweets = build_many(:extwitter_tweet, 3)
    photo_tweets = build_many(:extwitter_photo_tweet, 3)
    tweets = Enum.shuffle(normal_tweets ++ photo_tweets)
    timeline = create(:home_timeline, user_id: create(:user).id)
    :ok = GenServer.call(Collector, {:collect, timeline, tweets})

    assert count_inserted(normal_tweets) == 0
    assert count_inserted(photo_tweets) == length(photo_tweets)
  end

  test "collector deals with duplicate photo tweets" do
    all_tweets = build_many(:extwitter_photo_tweet, 6)
    [tweets1, overlap, tweets2] = Enum.chunk(all_tweets, 2)
    timeline = create(:home_timeline, user_id: create(:user).id)
    :ok = GenServer.call(Collector, {:collect, timeline, tweets1 ++ overlap})

    timeline = Repo.reload(timeline)
    :ok = GenServer.call(Collector, {:collect, timeline, overlap ++ tweets2})

    assert count_inserted(all_tweets) == length(all_tweets)

    ids = Enum.map(all_tweets, &Map.get(&1, :id))
    timeline_count =
      from(t in TimelineTweet,
        select: count(t.id),
        where: t.tweet_id in ^ids)
      |> Repo.one

    assert timeline_count == length(all_tweets) + length(overlap)
  end

  test "collector discards tweets if timeline has changed since fetch requested" do
    tweets1 = build_many(:extwitter_photo_tweet, 3)
    tweets2 = build_many(:extwitter_photo_tweet, 3)
    timeline = create(:home_timeline, user_id: create(:user).id)
    :ok = GenServer.call(Collector, {:collect, timeline, tweets1})

    # Start collector with outdated timeline.
    :ok = GenServer.call(Collector, {:collect, timeline, tweets2})

    assert count_inserted(tweets1) == length(tweets1)
    assert count_inserted(tweets2) == 0
  end

  test "collector updates timeline.collected_at after collecting photo tweets" do
    timeline = create(:home_timeline, user_id: create(:user).id)

    assert timeline.collected_at == nil

    t = Ecto.DateTime.utc
    photo_tweets = build_many(:extwitter_photo_tweet, 3)
    :ok = GenServer.call(Collector, {:collect, timeline, photo_tweets})
    collected_at = Repo.reload(timeline).collected_at

    assert Ecto.DateTime.compare(collected_at, t) in [:eq, :gt]
  end

  test "collector updates timeline.collected_at even after collecting no photo tweets" do
    timeline = create(:home_timeline, user_id: create(:user).id)

    assert timeline.collected_at == nil

    t = Ecto.DateTime.utc
    normal_tweets = build_many(:extwitter_tweet, 3)
    :ok = GenServer.call(Collector, {:collect, timeline, normal_tweets})
    collected_at = Repo.reload(timeline).collected_at

    assert Ecto.DateTime.compare(collected_at, t) in [:eq, :gt]
  end
end
