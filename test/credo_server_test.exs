defmodule CredoServerTest do
  use ExUnit.Case
  use Plug.Test
  alias CredoServer.{Router, TestUtils}

  @router_opts Router.init([])

  test "root redirect to /repos when logged in" do
    Ecto.Adapters.SQL.restart_test_transaction(CredoServer.Repo)
    conn = 
      conn(:get, "/") 
      |> TestUtils.sign_conn
      |> TestUtils.login_user
      |> Router.call(@router_opts)

    assert conn.status == 302
    assert hd(get_resp_header(conn, "location")) =~ "/repos"
  end

  test "root redirect " do
    Ecto.Adapters.SQL.restart_test_transaction(CredoServer.Repo)
    conn =
      conn(:get, "/invalid_url") 
      |> TestUtils.sign_conn
      |> TestUtils.login_user
      |> Router.call(@router_opts)

    assert conn.status == 404
  end
end
