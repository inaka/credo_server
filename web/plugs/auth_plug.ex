defmodule CredoServer.Plug.Auth do
  @moduledoc """
  A Plug to authenticate HTTP requests.

  ## Examples
      CredoServer.Plug.Auth.call(conn, [])
  """

  @behaviour Plug

  import Plug.Conn
  alias CredoServer.User

  ## Plug callbacks

  def init(opts) do
    opts
  end

  # Private

  def call(conn, _opts)  do
    check_session(conn, get_session(conn, :user))
  end

  defp check_session(conn, nil) do
    redirect_to_auth(conn)
  end
  defp check_session(conn, session) do
    case User.find_by_auth_token(session.token) do
      nil ->
        redirect_to_auth(conn)
      valid_user ->
        assign(conn, :user, valid_user)
    end
  end

  defp redirect_to_auth(conn) do
    conn
    |> Phoenix.Controller.redirect(to: "/auth")
    |> halt()
  end
end
