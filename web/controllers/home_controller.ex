defmodule CredoServer.HomeController do
  use CredoServer.Web, :controller

  def index(conn, _params) do
    redirect(conn, to: repository_path(conn, :index))
  end
end
