defmodule CredoServer.HomeController do
  @moduledoc false

  import Plug.Conn
  require EEx

  EEx.function_from_file :def, :home, "web/templates/home.html.eex"

  def index(conn) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, home)
  end
end
