defmodule CredoServer.RouterHelper do
  @moduledoc false

  import Plug.Conn

  def redirect(conn, opts) do
    url  = opts[:to]
    html = Plug.HTML.html_escape(url)
    body = "<html><body>You are being <a href=\"#{html}\">redirected</a>.</body></html>"

    conn
    |> put_resp_header("location", url)
    |> put_resp_content_type("text/html")
    |> send_resp(conn.status || 302, body)
  end
end
