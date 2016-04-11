defmodule CredoServer.HomeController do
  require EEx
  EEx.function_from_file :def, :home, "web/templates/home.html.eex"

  def index(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> Plug.Conn.send_resp(200, home)
  end
end
