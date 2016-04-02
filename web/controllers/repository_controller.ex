defmodule CredoServer.RepositoryController do
  use CredoServer.Web, :controller

  alias CredoServer.Repository
  alias CredoServer.User


  def index(conn, _params) do
    user = conn.assigns.user
    public_repos = User.public_repos(user)

    render(conn, "index.html", public_repos: public_repos)
  end
end
