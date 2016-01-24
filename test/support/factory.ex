defmodule Tev.Factory do
  use ExMachina.Ecto, repo: Tev.Repo

  alias Tev.User

  def factory(:user) do
    %User{
      id: sequence(:user_id, &(&1)),
      screen_name: sequence(:user_screen_name, &"user_#{&1}"),
    }
  end
end
