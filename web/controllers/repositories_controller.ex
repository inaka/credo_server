defmodule CredoServer.RepositoriesController do
  @moduledoc false

  import Plug.Conn
  require EEx
  require Ecto.Query

  EEx.function_from_file(:def, :index_template, "web/templates/repositories/index.html.eex", [:public_repos])

  alias CredoServer.Repository
  alias CredoServer.User
  alias CredoServer.Repo

  def index(conn) do
    user = conn.assigns.user

    if (user.synced_at == nil), do: User.sync_repositories(user)
    query = Ecto.assoc(user, :repositories) |> Ecto.Query.order_by([r], r.full_name)
    repos = Repo.all(query)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, index_template(repos))
  end

  def add_webhook(conn, repository_id) do
     user = conn.assigns.user
     repository = Repo.get(Repository, repository_id)

     case Repository.add_webhook(repository, user) do
       :ok ->
         body = "<html><body>You are being redirected</body></html>"
         conn
         |> put_resp_header("location", "/repos")
         |> put_resp_content_type("text/html")
         |> send_resp(conn.status || 302, body)
       :error ->
         send_resp(conn, 422, "There was a problem adding the webhook")
     end
  end

  def remove_webhook(conn, repository_id) do
     user = conn.assigns.user
     repository = Repo.get(Repository, repository_id)
     Repository.remove_webhook(repository, user)

     body = "<html><body>You are being redirected</body></html>"
     conn
     |> put_resp_header("location", "/repos")
     |> put_resp_content_type("text/html")
     |> send_resp(conn.status || 302, body)
  end

  def webhook(conn) do
    {:ok, body, _} = read_body(conn)
    {:ok, response_body} = Poison.decode(body)
    repo = Repo.get_by(Repository, full_name: response_body["repository"]["full_name"])
    IO.inspect "webhook for => " <> repo.full_name

    send_resp(conn, :no_content, "")
  end
end
