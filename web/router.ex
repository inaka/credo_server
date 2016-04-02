defmodule CredoServer.Router do
  use CredoServer.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", CredoServer do
    pipe_through :browser
    get "/auth", AuthController, :index
    post  "/auth/oauth/login", AuthController, :login
    get   "/auth/oauth/callback", AuthController, :callback
    get   "/auth/oauth/logout", AuthController, :logout
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug CredoServer.Plug.Auth
  end

  scope "/", CredoServer do
    pipe_through :browser
    pipe_through :api

    get "/repos", RepositoryController, :index

    get "/test", TestController, :show
    get "/",  HomeController, :index
  end
end
