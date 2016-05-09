defmodule CredoServer.RepositoriesControllerTest do
  use Plug.Test
  alias CredoServer.Router
  alias CredoServer.Repo
  alias CredoServer.Repository
  alias CredoServer.User
  alias CredoServer.TestUtils

  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    Ecto.Adapters.SQL.restart_test_transaction(CredoServer.Repo)
    :ok
  end

  @router_opts Router.init([])

  test "sync user repositories when user is not sync" do
    Ecto.Adapters.SQL.restart_test_transaction(CredoServer.Repo)
    use_cassette "repositories_sync" do
      conn = conn(:get, "/repos") |> TestUtils.sign_conn
      conn = TestUtils.login_user(conn)
      conn = Router.call(conn, @router_opts)

      user = Repo.get_by(User, auth_token: conn.assigns[:user].auth_token)
      assert user.synced_at
      assert 1 == Repo.all(Repository) |> Enum.count
      assert conn.status == 200
    end
  end

  test "do not sync repos if already synced" do
    Ecto.Adapters.SQL.restart_test_transaction(CredoServer.Repo)
    conn = conn(:get, "/repos") |> TestUtils.sign_conn
    conn = TestUtils.login_user(conn)
    user = Repo.get_by(User, auth_token: conn.assigns[:user].auth_token)
    user_change = Ecto.Changeset.change(user, synced_at: Ecto.DateTime.utc)
    Repo.update(user_change)
    conn = Router.call(conn, @router_opts)

    assert 0 == Repo.all(Repository) |> Enum.count
    assert conn.status == 200
  end

  test "add webhook to repo" do
    use_cassette "add_webhook" do
      Ecto.Adapters.SQL.restart_test_transaction(CredoServer.Repo)
      user = TestUtils.create_user()
      repo_info = [github_id: 56711785, name: "credo_test",
                   full_name: "alemata/credo_test",
                   html_url: "https://github.com/alemata/credo_test",
                   status: "off"]
      repo_info = Ecto.build_assoc(user, :repositories, repo_info)

      {:ok, repo} = Repo.insert(repo_info)

      conn = conn(:post, "/repos/#{repo.id}/webhook") |> TestUtils.sign_conn
      conn = TestUtils.login_user(conn, user)

      conn = Router.call(conn, @router_opts)

      repo = Repo.get_by(Repository, github_id: 56711785)
      assert repo.status == "on"
      assert conn.status == 302
      assert hd(get_resp_header(conn, "location")) == "/repos"
    end
  end

  test "remove webhook from repo" do
    use_cassette "remove_webhook" do
      Ecto.Adapters.SQL.restart_test_transaction(CredoServer.Repo)
      user = TestUtils.create_user()
      repo_info = [github_id: 56711785, name: "credo_test",
                   full_name: "alemata/credo_test",
                   html_url: "https://github.com/alemata/credo_test",
                   status: "on"]
      repo_info = Ecto.build_assoc(user, :repositories, repo_info)

      {:ok, repo} = Repo.insert(repo_info)

      conn = conn(:delete, "/repos/#{repo.id}/webhook") |> TestUtils.sign_conn
      conn = TestUtils.login_user(conn, user)

      conn = Router.call(conn, @router_opts)

      repo = Repo.get_by(Repository, github_id: 56711785)
      assert repo.status == "off"
      assert conn.status == 302
      assert hd(get_resp_header(conn, "location")) == "/repos"
    end
  end

  test "call egithub webhook on github event" do
    Ecto.Adapters.SQL.restart_test_transaction(CredoServer.Repo)
    user = TestUtils.create_user()
    repo_info = [github_id: 56711785, name: "credo_test",
                 full_name: "alemata/credo_test",
                 html_url: "https://github.com/alemata/credo_test",
                 status: "on"]
    repo_info = Ecto.build_assoc(user, :repositories, repo_info)

    {:ok, repo} = Repo.insert(repo_info)

    conn = conn(:post, "/webhook", %{"repository" => %{"full_name" => "alemata/credo_test"}}) |> TestUtils.sign_conn
    conn = Router.call(conn, @router_opts)

    assert conn.status == 204
  end
end
