defmodule CredoServer.RepositoryController do
  use CredoServer.Web, :controller

  alias CredoServer.Repository


  def index(conn, _params) do
    render(conn, "index.html")
  end
end
