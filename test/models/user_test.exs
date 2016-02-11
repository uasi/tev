defmodule Tev.UserTest do
  use Tev.ModelCase

  alias Tev.Timeline
  alias Tev.User

  @valid_attrs %{screen_name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "ensure_timelines_exist ensures timelines exist" do
    user = factory(:extwitter_user)
    refute Repo.get_by(Timeline, user_id: user.id)

    user
    |> User.from_user_object
    |> User.ensure_timelines_exist
    assert Repo.get_by(Timeline, user_id: user.id).type == :home
  end
end
