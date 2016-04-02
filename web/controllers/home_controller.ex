defmodule CredoServer.HomeController do
  use CredoServer.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
