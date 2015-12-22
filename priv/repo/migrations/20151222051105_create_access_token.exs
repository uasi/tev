defmodule Tev.Repo.Migrations.CreateAccessToken do
  use Ecto.Migration

  def change do
    create table(:access_tokens) do
      add :oauth_token_encrypted, :binary
      add :oauth_token_secret_encrypted, :binary
      add :user_id, references(:users)

      timestamps
    end
    create index(:access_tokens, [:user_id])

  end
end
