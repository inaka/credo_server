defmodule CredoServer.Router do
  use CredoServer.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :external do
    plug :accepts, ["html"]
  end

  scope "/", CredoServer do
    pipe_through :external
    post "/webhook", RepositoryController, :webhook
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

    resources "/repos", RepositoryController, only: [:index] do
      post "/on", RepositoryController, :on
      post "/off", RepositoryController, :off
    end

    get "/test", TestController, :show
    get "/",  HomeController, :index
  end
end
