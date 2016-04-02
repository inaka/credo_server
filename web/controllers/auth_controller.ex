defmodule CredoServer.AuthController do
  use CredoServer.Web, :controller

  alias CredoServer.Home
  alias CredoServer.User

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def login(conn, _params) do
    query_params = "client_id=" <> Application.get_env(:credo_server, :github_client_id) <> "&scope=" <> Application.get_env(:credo_server, :github_scope)
    login_url = "https://github.com/login/oauth/authorize?" <> query_params
    redirect(conn, external: login_url)
  end

  def callback(conn, _params) do
    params = %{client_id: Application.get_env(:credo_server, :github_client_id),
               client_secret: Application.get_env(:credo_server, :github_client_secret),
               code: conn.query_params["code"]}

    response = HTTPoison.post!('https://github.com/login/oauth/access_token',
                               URI.encode_query(params),
                               [{"Content-Type", "application/x-www-form-urlencoded"},
                                {"Accept", "application/json"}])

    {:ok, response_body} = Poison.decode(response.body)

    user = User.save(response_body["access_token"])

    conn
    |> put_session(:user, %{token: user.auth_token})
    |> redirect(to: repository_path(conn, :index))
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:user)
    |> redirect(to: auth_path(conn, :index))
  end
end
