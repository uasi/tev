defmodule Tev.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :twitter_id_str, :string
      add :twitter_screen_name, :string

      timestamps
    end
    create unique_index(:users, [:twitter_id_str])

  end
end
