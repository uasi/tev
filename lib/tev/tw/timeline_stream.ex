defmodule Tev.Tw.TimelineStream do
  @moduledoc """
  Provides `home_timeline/2` that produces all available tweets in a home timeline.
  """

  @doc """
  Creates a stream that emits `ExTwitter.Model.Tweet` structs.

  Tweets are usually sorted by newest first order, though not guaranteed.

  Raises `ExTwitter.RateLimitExceededError` if it reaches the rate limit.

  Raises `ExTwitter.Error` for other Twitter API-related errors.
  """
  @spec home_timeline(max_id: integer, since_id: integer)
        :: [ExTwitter.Model.Tweet.t] | no_return
  def home_timeline(opts) do
    default_max_id = Keyword.get(opts, :max_id)
    since_id = Keyword.get(opts, :since_id)

    Stream.resource(
      fn -> nil end,
      fn last_tweet ->
        max_id = if last_tweet, do: last_tweet.id - 1, else: default_max_id
        case get_tweets(max_id: max_id, since_id: since_id) do
          [] ->
            {:halt, nil}
          tweets ->
            {tweets, List.last(tweets)}
        end
      end,
      fn _ -> nil end
    )
  end

  @spec get_tweets(max_id: integer, since_id: integer)
        :: [ExTwitter.Model.Tweet.t] | no_return
  defp get_tweets(opts) do
    opts = Enum.reject(opts, fn {_k, v} -> v == nil end)
    ExTwitter.home_timeline(opts ++ [count: 1000])
  end
end
