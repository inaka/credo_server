defmodule CredoServer.UsersControllerTest do
  use Plug.Test
  alias CredoServer.{Router, Repo, User, TestUtils}
  use ExUnit.Case, async: true

  @router_opts Router.init([])

  test "active users returns number of active users" do
    user = TestUtils.create_user()
    repo_fields = %{github_id: 56711785, name: "credo_test",
                    full_name: "alemata/credo_test",
                    html_url: "https://github.com/alemata/credo_test",
                    status: "on"}
    repo_info = Ecto.build_assoc(user, :repositories, repo_fields)
    Repo.insert(repo_info)

    conn =
      conn(:get, "/users/active")
      |> TestUtils.sign_conn
      |> Router.call(@router_opts)

    assert conn.status == 200
  end
end
