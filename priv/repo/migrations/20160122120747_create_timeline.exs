defmodule Tev.Repo.Migrations.CreateTimeline do
  use Ecto.Migration

  def change do
    create table(:timelines) do
      add :type, :integer, null: false
      add :max_tweet_id, :bigint
      add :fetch_started_at, :datetime
      add :collected_at, :datetime

      add :user_id, references(:users, type: :bigint, on_delete: :delete_all), null: false

      timestamps
    end

    create index(:timelines, [:user_id, :type])
  end
end
