defmodule CredoServer.Router do
  @moduledoc false

  use Plug.Router
  import CredoServer.Plug.AddSecretKey
  import CredoServer.Plug.Auth

  alias CredoServer.RepositoriesController
  alias CredoServer.UsersController
  alias CredoServer.AuthController
  import CredoServer.RouterHelper

  plug Plug.Static,
    at: "/",
    from: :credo_server

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride

  plug Plug.Logger, log: :debug

  plug Plug.Session,
    store: :cookie,
    key: "_credo_server_key",
    signing_salt: "Jk7pxAMf",
    encryption_salt: "Jk7pxAMf"

  plug :add_secret_key
  plug :fetch_session
  plug :check_user
  plug :match
  plug :dispatch

  # Root path
  get "/" do
    redirect(conn, to: "/repos")
  end

  # Root path
  get "/repos" do
    RepositoriesController.index(conn)
  end

  post "/repos/:repository_id/webhook" do
    RepositoriesController.add_webhook(conn, repository_id)
  end

  delete "/repos/:repository_id/webhook" do
    RepositoriesController.remove_webhook(conn, repository_id)
  end

  # Route for the events from github
  post "/webhook" do
    RepositoriesController.webhook(conn)
  end

  get "/auth" do
    AuthController.index(conn)
  end

  post "/auth/oauth/login" do
    AuthController.login(conn)
  end

  get "/auth/oauth/logout" do
    AuthController.logout(conn)
  end

  get "/auth/oauth/callback" do
    AuthController.callback(conn)
  end

  get "/users/active" do
    UsersController.active_users(conn)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
