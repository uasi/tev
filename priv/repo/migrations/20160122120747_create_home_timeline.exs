defmodule Tev.Repo.Migrations.CreateHomeTimeline do
  use Ecto.Migration

  def change do
    create table(:home_timelines) do
      add :max_tweet_id, :bigint
      add :user_id, references(:users, type: :bigint, on_delete: :delete_all), null: false

      timestamps
    end

    create unique_index(:home_timelines, [:user_id])
  end
end
