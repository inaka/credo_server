defmodule CredoServer.RepositoryController do
  use CredoServer.Web, :controller

  alias CredoServer.Repository
  alias CredoServer.User


  def index(conn, _params) do
    user = conn.assigns.user

    if (user.synced_at == nil) do
      Repo.delete_all assoc(user, :repositories)
      public_repos = User.public_repos(user)
      Enum.map(public_repos, fn(repo) ->
        # TODO check status of the repo
        # client = Tentacat.Client.new(%{access_token: user.github_token})
        # hooks = Tentacat.Hooks.list(user.username, repo["name"], client)

        #build_assoc not working!
        changeset = Repository.changeset(%Repository{}, %{github_id: repo["id"],
                                                        name: repo["name"], full_name: repo["full_name"],
                                                        html_url: repo["html_url"], status: "off"})

        {:ok, saved_repo} = Repo.insert(changeset)
        change = Ecto.Changeset.change(saved_repo, user_id: user.id)
        Repo.update(change)
      end)
      user_change = Ecto.Changeset.change(user, synced_at: Ecto.DateTime.local)
      Repo.update(user_change)
    end

    repos = Repo.all assoc(user, :repositories)

    render(conn, "index.html", public_repos: repos)
  end

  def on(conn, %{"repository_id" => repository_id}) do
    user = conn.assigns.user
    repo = Repo.get(Repository, repository_id)

    hook_body = %{
      "name" => "web",
      "active" => true,
      "events" => ["pull_request"],
      "config" => %{
        "url" => Application.get_env(:credo_server, :webhook_url),
        "content_type" => "json"
      }
    }

    client = Tentacat.Client.new(%{access_token: user.github_token})
    Tentacat.Hooks.create(user.username, repo.name, hook_body, client)

    redirect(conn, to: repository_path(conn, :index))
  end

  def webhook(conn, params) do
    repo = Repo.get_by(Repository, full_name: params["repository"]["full_name"])
    IO.inspect "webhook for => " <> repo.full_name

    send_resp(conn, :no_content, "")
  end

end
