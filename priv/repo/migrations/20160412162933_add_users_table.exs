defmodule CredoServer.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :username, :string
      add :github_token, :string
      add :email, :string
      add :email_code, :string
      add :auth_token, :string
      add :auth_expires, :datetime
      add :synced_at, :datetime

      timestamps
    end
  end
end
