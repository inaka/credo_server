defmodule CredoServer.Router do
  use Plug.Router
  plug Plug.Logger, log: :debug

  plug :match
  plug :dispatch

  # Root path
  get "/" do
    CredoServer.HomeController.index(conn)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
