defmodule Tev.Repo.Migrations.CreateTweet do
  use Ecto.Migration

  def change do
    create table(:tweets, primary_key: false) do
      add :id, :bigint, null: false, primary_key: true
      add :object, :map, null: false
    end
  end
end
