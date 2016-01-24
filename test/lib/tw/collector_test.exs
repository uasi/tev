defmodule Tev.Tw.CollectorTest do
  use ExUnit.Case, async: true

  import Ecto.Query, only: [from: 2]
  import Tev.Factory

  alias Tev.Repo
  alias Tev.Tw.Collector
  alias Tev.Tweet

  defp build_many(tag, n) do
    Stream.repeatedly(fn -> build(tag) end)
    |> Enum.take(n)
    |> Enum.to_list
  end

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
    photo_tweets = build_many(:extwitter_photo_tweet, 5)
    photo_tweets_1 = Enum.take(photo_tweets, length(photo_tweets) - 1)
    photo_tweets_2 = Enum.drop(photo_tweets, 1)
    timeline = create(:home_timeline, user_id: create(:user).id)

    :ok = GenServer.call(Collector, {:collect, timeline, photo_tweets_1})
    :ok = GenServer.call(Collector, {:collect, timeline, photo_tweets_2})

    assert count_inserted(photo_tweets) == length(photo_tweets)
  end
end
