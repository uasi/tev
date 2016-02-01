defmodule Tev.Repo.Migrations.CreateTimelineTweet do
  use Ecto.Migration

  def change do
    create table(:timeline_tweets) do
      add :timeline_id, references(:timelines, on_delete: :delete_all), null: false
      add :tweet_id, references(:tweets, type: :bigint, on_delete: :delete_all), null: false

      timestamps
    end

    create index(:timeline_tweets, [:timeline_id, :tweet_id])
  end
end
