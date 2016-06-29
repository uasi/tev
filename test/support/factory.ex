defmodule Tev.Factory do
  use ExMachina.Ecto, repo: Tev.Repo

  alias Tev.Timeline
  alias Tev.User

  def user_factory do
    %User{
      id: sequence(:user_id, &(&1)),
      screen_name: sequence(:user_screen_name, &"user_#{&1}"),
    }
  end

  def home_timeline_factory do
    %Timeline{
      user_id: sequence(:user_id, &(&1)),
      type: Timeline.Type.cast(:home) |> elem(1),
    }
  end

  def extwitter_tweet_factory do
    id = sequence(:extwitter_tweet_id, &(&1))
    %ExTwitter.Model.Tweet{
      id: id,
      id_str: "#{id}",
    }
  end

  def extwitter_photo_tweet_factory do
    %{build(:extwitter_tweet) | extended_entities: %{media: [%{type: "photo"}]}}
  end

  def extwitter_user_factory do
    %ExTwitter.Model.User{
      id: sequence(:user_id, &(&1)),
      screen_name: sequence(:user_screen_name, &"user_#{&1}"),
    }
  end
end
