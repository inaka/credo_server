defmodule CredoServer.RepositoriesController do
  @moduledoc false

  alias CredoServer.{Repository, User, Repo, GithubUtils, CredoWebhook, Render}

  import CredoServer.RouterHelper
  import Plug.Conn

  def index(conn) do
    user = conn.assigns.user

    if (user.synced_at == nil), do: User.sync_repositories(user)
    query = User.repositories_query(user)
    repos = Repo.all(query)

    conn
    |> assign(:public_repositories, repos)
    |> Render.render(&Render.repositories_index/1)
  end

  def sync(conn) do
    user = conn.assigns.user
    User.sync_repositories(user)

    send_resp(conn, 200, "ok")
  end

  def add_webhook(conn, repository_id) do
     user = conn.assigns.user
     repository = Repo.get(Repository, repository_id)

     case Repository.add_webhook(repository, user) do
       :ok ->
         send_resp(conn, 200, "ok")
       :error ->
         send_resp(conn, 422, "There was a problem adding the webhook")
     end
  end

  def remove_webhook(conn, repository_id) do
     user = conn.assigns.user
     repository = Repo.get(Repository, repository_id)
     Repository.remove_webhook(repository, user)

     send_resp(conn, 200, "ok")
  end

  def webhook(conn) do
    response_body = conn.body_params
    repository_name = response_body["repository"]["full_name"]
    repository = Repository.get_repository_with_user(repository_name)
    repository_user = repository.user
    status_cred = GithubUtils.oauth(repository_user.github_token)
    headers_map = Enum.into(conn.req_headers, %{})
    request_map = %{headers: headers_map, body: Poison.encode!(response_body)}
    cred = GithubUtils.basic_auth()

    GithubUtils.event(CredoWebhook, status_cred,
                      'Credo', 'credo',
                      cred, request_map)

    send_resp(conn, :no_content, "")
  end
end
