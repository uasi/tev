defmodule Tev.PageView do
  defstruct [:user, :page]
  @type t :: %__MODULE__{}

  use Tev.Web, :view

  import Ecto, only: [assoc: 2]
  import Ecto.Query, only: [order_by: 2]

  alias Tev.Repo
  alias Tev.Tweet
  alias Tev.User

  @spec new(%{}, User.t) :: t
  def new(params, user) do
    page =
      user
      |> assoc(:home_timeline)
      |> Repo.one!
      |> assoc(:tweets)
      |> order_by(desc: :id)
      |> Repo.paginate(params)
    %__MODULE__{user: user, page: page}
  end

  @spec tweets_to_photo_urls([Tweet.t]) :: [binary]
  defp tweets_to_photo_urls(tweets) do
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
