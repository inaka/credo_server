defmodule CredoServer.Plug.Auth do
  @moduledoc """
  A Plug to authenticate HTTP requests.

  ## Examples
      CredoServer.Plug.Auth.call(conn, [])
  """

  @behaviour Plug

  import Plug.Conn
  require Logger
  alias CredoServer.Repo
  alias CredoServer.User

  ## Plug callbacks

  def init(opts) do
    opts
  end

  def call(conn, _opts)  do
    case get_token(conn) do
      nil ->
        assign(conn, :user, nil)
      token ->
        user = User.find_by_auth_token(token)
        assign(conn, :user, user)
    end
  end

  ## Private functions

  defp get_token(conn) do
    new_conn = fetch_cookies conn
    new_conn.req_cookies["token"]
  end

  @doc """
  Authentication macro. This macro contains a function-based plug
  to be used in the controllers in order to be able to authenticate
  the HTTP request in each controller.

  ## Example

      defmodule CredoServer.TestController do
        use CredoServer.Web, :controller

        import CredoServer.Router.Helpers

        plug :authenticate when action in [:show]

        def show(conn, _opts) do
          # logic
        end
      end
  """
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      
      def init(opts) do
        opts
      end

      def authenticate(conn, _opts) do
        if conn.assigns.user do
          conn
        else
          conn
            |> send_resp(401, "UNAUTHORIZED")
            |> halt()
        end
      end

      defoverridable [init: 1, authenticate: 2]
    end
  end
end