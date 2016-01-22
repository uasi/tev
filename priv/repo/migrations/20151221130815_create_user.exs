defmodule Tev.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :integer, null: false, primary_key: true
      add :screen_name, :string, null: false

      timestamps
    end
  end
end
