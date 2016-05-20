defmodule CredoServer.Repo.Migrations.AddOwnerDataToRepositories do
  use Ecto.Migration
  alias CredoServer.{Repo, Repository}

  def change do
    repos = Repo.all(Repository)
    Enum.map(repos, fn (repo) ->
      [owner, _] = String.split(repo.full_name, "/")
      repo_change = Ecto.Changeset.change(repo, owner: owner)
      Repo.update(repo_change)
    end)
  end
end
