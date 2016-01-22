defmodule Tev.Repo.Migrations.CreateAccessToken do
  use Ecto.Migration

  def change do
    create table(:access_tokens) do
      add :oauth_token_encrypted, :binary, null: false
      add :oauth_token_secret_encrypted, :binary, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps
    end
    create unique_index(:access_tokens, [:user_id])

  end
end
