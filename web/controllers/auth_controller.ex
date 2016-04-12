defmodule CredoServer.AuthController do
  @moduledoc false

  import Plug.Conn

  require EEx
  EEx.function_from_file :def, :sing_up, "web/templates/sign_up.html.eex"

  def index(conn) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, sing_up)
  end

  def login(conn) do
    github_client_id = Application.get_env(:credo_server, :github_client_id)
    github_scope = Application.get_env(:credo_server, :github_scope)
    query_params = "client_id=#{github_client_id}&scope=#{github_scope}"
    login_url = "https://github.com/login/oauth/authorize?#{query_params}"

    body = "<html><body>You are being redirected</body></html>"
    conn
    |> put_resp_header("location", login_url)
    |> put_resp_content_type("text/html")
    |> send_resp(conn.status || 302, body)
  end

  def callback(conn) do
    conn = fetch_query_params(conn)
    access_token = get_github_access_token(conn.query_params["code"])
    user = CredoServer.User.save(access_token)

    body = "<html><body>You are being redirected</body></html>"
    conn
    |> put_session(:user, %{token: user.auth_token})
    |> put_resp_header("location", "/")
    |> put_resp_content_type("text/html")
    |> send_resp(conn.status || 302, body)
  end

  # Private

  defp get_github_access_token(code) do
    github_client_id = Application.get_env(:credo_server, :github_client_id)
    github_client_secret = Application.get_env(:credo_server, :github_client_secret)
    params = %{client_id: github_client_id,
               client_secret: github_client_secret,
               code: code}

    headers = [{"Content-Type", "application/x-www-form-urlencoded"},
               {"Accept", "application/json"}]
    response = HTTPoison.post!('https://github.com/login/oauth/access_token',
                               URI.encode_query(params),
                               headers)

    {:ok, response_body} = Poison.decode(response.body)
    response_body["access_token"]
  end
end
