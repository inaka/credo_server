defmodule CredoServer.Router do
  @moduledoc false

  use Plug.Router
  import CredoServer.Plug.AddSecretKey
  import CredoServer.Plug.Auth

  alias CredoServer.HomeController
  alias CredoServer.AuthController

  plug Plug.Logger, log: :debug

  plug Plug.Session,
    store: :cookie,
    key: "_credo_server_key",
    signing_salt: "Jk7pxAMf",
    encryption_salt: "Jk7pxAMf"

  plug :add_secret_key
  plug :fetch_session
  plug :match
  plug :dispatch

  # Root path
  get "/" do
    check_user(conn)
    HomeController.index(conn)
  end

  get "/auth" do
    AuthController.index(conn)
  end

  post "/oauth/login" do
    AuthController.login(conn)
  end

  get "/auth/oauth/callback" do
    AuthController.callback(conn)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
