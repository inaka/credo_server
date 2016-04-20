defmodule CredoServer.Repo.Migrations.AddRepositoriesTable do
  use Ecto.Migration

  def change do
    create table(:repositories) do
      add :user_id, references(:users)
      add :github_id, :integer
      add :name, :string
      add :full_name, :string
      add :html_url, :string
      add :private, :boolean, default: false
      add :status, :string

      timestamps
    end
  end
end
