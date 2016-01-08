defmodule CredoServer.RepositoryControllerTest do
  use CredoServer.ConnCase

  alias CredoServer.Repository

  @valid_attrs %{
    full_name: "some content",
    github_id: 42,
    html_url: "some content",
    name: "some content",
    private: true,
    status: "some content"
  }
  @invalid_attrs %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, repository_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    repository = Repo.insert! %Repository{}
    conn = get conn, repository_path(conn, :show, repository)
    assert json_response(conn, 200)["data"] == %{"id" => repository.id}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, repository_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, repository_path(conn, :create), repository: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Repository, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, repository_path(conn, :create), repository: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    repository = Repo.insert! %Repository{}
    conn = put conn, repository_path(conn, :update, repository), repository: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Repository, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    repository = Repo.insert! %Repository{}
    conn = put conn, repository_path(conn, :update, repository), repository: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    repository = Repo.insert! %Repository{}
    conn = delete conn, repository_path(conn, :delete, repository)
    assert response(conn, 204)
    refute Repo.get(Repository, repository.id)
  end
end
