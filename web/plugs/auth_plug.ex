defmodule CredoServer.Plug.Auth do
  @moduledoc false

  import Plug.Conn

  def check_user(conn) do
    check_session(conn, get_session(conn, :user))
  end

  # Private

  defp check_session(conn, nil) do
    redirect_to_auth(conn)
  end
  defp check_session(conn, session) do
    case CredoServer.User.find_by_auth_token(session.token) do
      nil ->
        redirect_to_auth(conn)
      valid_user ->
        assign(conn, :user, valid_user)
    end
  end

  defp redirect_to_auth(conn) do
    body = "<html><body>You are being redirected</body></html>"
    conn
    |> put_resp_header("location", "/auth")
    |> put_resp_content_type("text/html")
    |> send_resp(conn.status || 302, body)
    |> halt()
  end
end
