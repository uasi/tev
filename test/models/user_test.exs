defmodule Tev.UserTest do
  use Tev.ModelCase

  alias Tev.User

  @valid_attrs %{twitter_id_str: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "put_access_token" do

  end
end
