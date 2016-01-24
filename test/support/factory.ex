defmodule Tev.Factory do
  use ExMachina.Ecto, repo: Tev.Repo

  alias Tev.HomeTimeline
  alias Tev.User

  def factory(:user) do
    %User{
      id: sequence(:user_id, &(&1)),
      screen_name: sequence(:user_screen_name, &"user_#{&1}"),
    }
  end

  def factory(:home_timeline) do
    %HomeTimeline{
      id: sequence(:home_timeline_id, &(&1)),
      user_id: sequence(:user_id, &(&1)),
    }
  end

  def factory(:extwitter_tweet) do
    id = sequence(:extwitter_tweet_id, &(&1))
    %ExTwitter.Model.Tweet{
      id: id,
      id_str: "#{id}",
    }
  end

  def factory(:extwitter_photo_tweet) do
    %{build(:extwitter_tweet) | extended_entities: %{media: [%{type: "photo"}]}}
  end
end
