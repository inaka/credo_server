defmodule CredoServer.Plug.Auth do
  @moduledoc false

  import Plug.Conn
  import CredoServer.RouterHelper

  def check_user(conn, _) do
    if needs_auth_check(conn) do
      conn = check_session(conn, get_session(conn, :user))
    end

    conn
  end

  # Private

  defp needs_auth_check(conn) do
    conn.path_info == [] or hd(conn.path_info) == "repos"
  end

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
    conn
    |> redirect(to: "/auth")
    |> halt()
  end
end
