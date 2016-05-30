defmodule CredoServer.Repo.Migrations.RemoveUserEmailCode do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :email_code
    end
  end
end
