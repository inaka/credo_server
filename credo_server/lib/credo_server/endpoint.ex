defmodule CredoServer.Endpoint do
  use Phoenix.Endpoint, otp_app: :credo_server

  socket "/socket", CredoServer.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  plug Plug.Static,
    at: "/", from: :credo_server, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_credo_server_key",
    signing_salt: "/m7W2yzs"

  plug CredoServer.Router
end
