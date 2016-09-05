defmodule Tev.Factory do
end
# defmodule Tev.Factory do
#   use ExMachina.Ecto, repo: Tev.Repo

#   alias Tev.Timeline
#   alias Tev.User

#   @spec build_many(atom, integer) :: [term]
#   def build_many(tag, n) do
#     Stream.repeatedly(fn -> build(tag) end)
#     |> Enum.take(n)
#     |> Enum.to_list
#   end

#   def factory(:user) do
#     %User{
#       id: sequence(:user_id, &(&1)),
#       screen_name: sequence(:user_screen_name, &"user_#{&1}"),
#     }
#   end

#   def factory(:home_timeline) do
#     %Timeline{
#       user_id: sequence(:user_id, &(&1)),
#       type: Timeline.Type.cast(:home) |> elem(1),
#     }
#   end

#   def factory(:extwitter_tweet) do
#     id = sequence(:extwitter_tweet_id, &(&1))
#     %ExTwitter.Model.Tweet{
#       id: id,
#       id_str: "#{id}",
#     }
#   end

#   def factory(:extwitter_photo_tweet) do
#     %{build(:extwitter_tweet) | extended_entities: %{media: [%{type: "photo"}]}}
#   end

#   def factory(:extwitter_user) do
#     %ExTwitter.Model.User{
#       id: sequence(:user_id, &(&1)),
#       screen_name: sequence(:user_screen_name, &"user_#{&1}"),
#     }
#   end
# end
