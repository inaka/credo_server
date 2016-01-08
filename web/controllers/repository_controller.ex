defmodule CredoServer.RepositoryController do
  use CredoServer.Web, :controller

  alias CredoServer.Repository

  plug :scrub_params, "repository" when action in [:create, :update]

  def index(conn, _params) do
    repositories = Repo.all(Repository)
    render(conn, "index.json", repositories: repositories)
  end

  def create(conn, %{"repository" => repository_params}) do
    changeset = Repository.changeset(%Repository{}, repository_params)

    case Repo.insert(changeset) do
      {:ok, repository} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", repository_path(conn, :show, repository))
        |> render("show.json", repository: repository)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CredoServer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    repository = Repo.get!(Repository, id)
    render(conn, "show.json", repository: repository)
  end

  def update(conn, %{"id" => id, "repository" => repository_params}) do
    repository = Repo.get!(Repository, id)
    changeset = Repository.changeset(repository, repository_params)

    case Repo.update(changeset) do
      {:ok, repository} ->
        render(conn, "show.json", repository: repository)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CredoServer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    repository = Repo.get!(Repository, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(repository)

    send_resp(conn, :no_content, "")
  end
end
