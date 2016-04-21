defmodule CredoServer.RepositoriesController do
  @moduledoc false

  import Plug.Conn
  import CredoServer.RouterHelper
  require EEx
  require Ecto.Query

  EEx.function_from_file(:def, :index_template, "web/templates/repositories/index.html.eex", [:public_repos])

  alias CredoServer.Repository
  alias CredoServer.User
  alias CredoServer.Repo
  alias CredoServer.GithubUtils

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
         redirect(conn, to: "/repos")
       :error ->
         send_resp(conn, 422, "There was a problem adding the webhook")
     end
  end

  def remove_webhook(conn, repository_id) do
     user = conn.assigns.user
     repository = Repo.get(Repository, repository_id)
     Repository.remove_webhook(repository, user)

     redirect(conn, to: "/repos")
  end

  def webhook(conn) do
    response_body = conn.body_params
    repo = Repo.get_by(Repository, full_name: response_body["repository"]["full_name"])

    headers_map = Enum.into(conn.req_headers, %{})
    request_map = %{headers: headers_map, body: Poison.encode!(response_body)}

    #TODO use event/6
    cred = GithubUtils.git_credentials()
    :egithub_webhook.event(CredoServer.CredoWebhook, cred, request_map);

    send_resp(conn, :no_content, "")
  end
end
