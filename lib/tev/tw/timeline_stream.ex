defmodule Tev.Tw.TimelineStream do
  @moduledoc """
  Provides `timeline/2` that returns a stream of all available tweets in a
  timeline.

  Tweets are usually sorted by newest first order, though not guaranteed.
  """

  @type timeline_opt :: {:max_id, integer} | {:since_id, integer}
  @type timeline_ret :: [ExTwitter.Model.Tweet.t] | no_return
  @typep timeline_type :: :home | :like

  @doc """
  Returns a stream of all available tweets in a timeline.

  Raises `ExTwitter.RateLimitExceededError` if it reaches the rate limit.

  Raises `ExTwitter.Error` for other Twitter API-related errors.
  """
  @spec timeline(timeline_type, [timeline_opt]) :: timeline_ret
  def timeline(type, opts) do
    default_max_id = Keyword.get(opts, :max_id)
    since_id = Keyword.get(opts, :since_id)

    Stream.resource(
      fn -> nil end,
      fn last_tweet ->
        max_id = if last_tweet, do: last_tweet.id - 1, else: default_max_id
        case get_tweets(type, [max_id: max_id, since_id: since_id]) do
          [] ->
            {:halt, nil}
          tweets ->
            {tweets, List.last(tweets)}
        end
      end,
      fn _ -> nil end
    )
  end

  @spec get_tweets(timeline_type, [timeline_opt]) :: timeline_ret
  defp get_tweets(type, opts) do
    opts = Enum.reject(opts, fn {_k, v} -> v == nil end) ++ [count: 1000]
    case type do
      :home -> ExTwitter.home_timeline(opts)
      :like -> ExTwitter.favorites(opts)
    end
  end
end
