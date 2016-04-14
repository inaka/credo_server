defmodule CredoServer.Router do
  @moduledoc false

  use Plug.Router
  import CredoServer.Plug.AddSecretKey
  import CredoServer.Plug.Auth

  alias CredoServer.RepositoriesController
  alias CredoServer.AuthController

  plug Plug.Static,
    at: "/",
    from: :credo_server

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
    body = "<html><body>You are being redirected</body></html>"
    conn
    |> put_resp_header("location", "/repos")
    |> put_resp_content_type("text/html")
    |> send_resp(conn.status || 302, body)
  end

  # Root path
  get "/repos" do
    conn = check_user(conn)
    RepositoriesController.index(conn)
  end

  post "/repos/:repository_id/add_webhook" do
    conn = check_user(conn)
    RepositoriesController.add_webhook(conn, repository_id)
  end

  post "/repos/:repository_id/remove_webhook" do
    conn = check_user(conn)
    RepositoriesController.remove_webhook(conn, repository_id)
  end

  # Route for the events from github
  post "/webhook" do
    RepositoriesController.webhook(conn)
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
