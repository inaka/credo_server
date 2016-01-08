defmodule CredoServer.RepositoryView do
  use CredoServer.Web, :view

  def render("index.json", %{repositories: repositories}) do
    %{data: render_many(repositories, CredoServer.RepositoryView, "repository.json")}
  end

  def render("show.json", %{repository: repository}) do
    %{data: render_one(repository, CredoServer.RepositoryView, "repository.json")}
  end

  def render("repository.json", %{repository: repository}) do
    %{id: repository.id}
  end
end
