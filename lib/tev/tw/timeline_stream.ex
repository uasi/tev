defmodule Tev.Tw.TimelineStream do
  @moduledoc """
  Provides `stream/2` that produces all available tweets in a timeline.
  """

  @type rate_limit_marker :: {:rate_limit_exceeded, %ExTwitter.RateLimitExceededError{}}

  @doc """
  Creates a stream that emits `ExTwitter.Model.Tweet` structs.

  Tweets are sorted by newest first order in almost all cases, though not
  guaranteed.

  Raises `ExTwitter.RateLimitExceededError` if it reaches the rate limit.

  Raises `ExTwitter.Error` for other Twitter API-related errors.
  """
  @spec home_timeline(integer, max_id: integer, since_id: integer)
        :: [ExTwitter.Model.Tweet.t | rate_limit_marker] | no_return
  def home_timeline(list_id, opts) do
    default_max_id = Keyword.get(opts, :max_id)
    since_id = Keyword.get(opts, :since_id)

    Stream.resource(
      fn -> nil end,
      fn
        [] ->
          {:halt, nil}
        [{:rate_limit_exceeded, _}] ->
          {:halt, nil}
        prev_tweets ->
          max_id = get_max_id_or_default(prev_tweets, default_max_id)
          tweets = get_tweets(list_id: list_id, max_id: max_id, since_id: since_id)
          {tweets, tweets}
      end,
      fn _ -> nil end
    )
  end

  @spec get_max_id_or_default([ExTwitter.Model.Tweet.t], integer) :: integer
  defp get_max_id_or_default(tweets = [_|_], _default) do
    List.last(tweets).id - 1
  end
  defp get_max_id_or_default(_tweets, default) do
    default
  end

  @spec get_tweets(list_id: integer, max_id: integer, since_id: integer)
        :: [ExTwitter.Model.Tweet.t | rate_limit_marker] | no_return
  defp get_tweets(opts) do
    opts = Enum.reject(opts, fn {_k, v} -> v == nil end)
    try do
      ExTwitter.home_timeline(opts ++ [count: 1000])
    rescue
      e in [ExTwitter.RateLimitExceededError] ->
        {:rate_limit_exceeded, e}
    end
  end
end
