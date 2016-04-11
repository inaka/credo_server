defmodule CredoServer.Router do
  use Plug.Router
  plug Plug.Logger, log: :debug

  plug :match
  plug :dispatch

  # Root path
  get "/" do
    send_resp(conn, 200, "Running without phoenix!")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
