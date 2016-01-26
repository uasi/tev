defmodule Tev.Repo.Migrations.CreateHomeTimelineTweet do
  use Ecto.Migration

  def change do
    create table(:home_timeline_tweets) do
      add :home_timeline_id, references(:home_timelines, on_delete: :delete_all), null: false
      add :tweet_id, references(:tweets, type: :bigint, on_delete: :delete_all), null: false

      timestamps
    end

    create index(:home_timeline_tweets, [:home_timeline_id, :tweet_id])
  end
end
