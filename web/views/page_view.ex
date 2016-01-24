defmodule Tev.PageView do
  defstruct [:user, :photo_urls]
  @type t :: %__MODULE__{}

  use Tev.Web, :view

  import Ecto, only: [assoc: 2]
  import Ecto.Query, only: [order_by: 2]

  alias Tev.Repo
  alias Tev.Tweet
  alias Tev.User

  @spec new(User.t) :: t
  def new(user) do
    photo_urls =
      user
      |> assoc(:home_timeline)
      |> Repo.one!
      |> assoc(:tweets)
      |> order_by(desc: :id)
      |> Repo.all
      |> to_photo_urls
    %__MODULE__{user: user, photo_urls: photo_urls}
  end

  @spec to_photo_urls([Tweet.t]) :: [binary]
  defp to_photo_urls(tweets) do
    tweets
    |> Stream.map(&photo_urls_in_tweet/1)
    |> Stream.concat
    |> Enum.to_list
  end

  @spec photo_urls_in_tweet(%{}) :: Stream.t | []
  defp photo_urls_in_tweet(%{object: %{"extended_entities" => %{"media" => media}}}) do
    media
    |> Stream.filter(&(&1["type"] == "photo"))
    |> Stream.map(&(&1["media_url"]))
  end
  defp photo_urls_in_tweet(_) do
    []
  end
end
