defmodule CredoServer.Router do
  use CredoServer.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug CredoServer.Plug.Auth
  end

  scope "/", CredoServer do
    pipe_through :api

    resources "/repos", RepositoryController

    get "/status", StatusController, :show
  end
end
