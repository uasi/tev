defmodule Tev.ApiController do
  use Tev.Web, :controller
  use Tev.Auth, authorize: true
  use Tev.Auth, :current_user

  alias Tev.ApiView
  alias Tev.Timeline
  alias Tev.Utils

  def rendered_tweets(conn, params = %{"timeline_type" => type}, user) do
    case Utils.string_to_any_of_atoms(type, Timeline.Type.tags) do
      {:ok, type} ->
        json conn, ApiView.rendered_tweets(params, user, type)
      :error ->
        raise_bad_request message: "timeline_type is invalid"
    end
  end
end
