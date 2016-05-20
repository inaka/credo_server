defmodule CredoServer.Repo.Migrations.AddOwnerToRepositories do
  use Ecto.Migration

  def change do
    alter table(:repositories) do
      add :owner, :string
    end
  end
end
