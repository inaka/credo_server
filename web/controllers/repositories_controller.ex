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
end
