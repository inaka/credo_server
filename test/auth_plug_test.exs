defmodule CredoServer.AuthPlugTest do
  use ExUnit.Case
  use Plug.Test
  import CredoServer.Plug.Auth
  alias CredoServer.TestUtils

  test "not logged in user" do
    Ecto.Adapters.SQL.restart_test_transaction(CredoServer.Repo)
    conn = conn(:get, "/repos") |> TestUtils.sign_conn()
    conn = check_user(conn, %{})
    assert conn.status == 302
    assert hd(get_resp_header(conn, "location")) == "/auth"
    refute conn.assigns[:user]
  end

  test "logged with an invalid token" do
    Ecto.Adapters.SQL.restart_test_transaction(CredoServer.Repo)
    conn = conn(:get, "/repos") |> TestUtils.sign_conn
    conn = put_session(conn, :user, %{auth_token: "invalidtoken"})
    conn = check_user(conn, %{})
    assert conn.status == 302
    assert hd(get_resp_header(conn, "location")) == "/auth"
    refute conn.assigns[:user]
  end

  test "logged with an expired token" do
    Ecto.Adapters.SQL.restart_test_transaction(CredoServer.Repo)
    now = Ecto.DateTime.utc
    expired = %Ecto.DateTime{day: now.day, hour: now.hour, min: now.min,
                             month: now.month, sec: now.sec, year: now.year - 1}
    user = TestUtils.create_user(expired)

    conn = conn(:get, "/repos") |> TestUtils.sign_conn
    conn = put_session(conn, :user, %{auth_token: user.auth_token})
    conn = check_user(conn, %{})
    assert conn.status == 302
    assert hd(get_resp_header(conn, "location")) == "/auth"
    refute conn.assigns[:user]
  end

  test "logged with a valid token" do
    Ecto.Adapters.SQL.restart_test_transaction(CredoServer.Repo)
    now = Ecto.DateTime.utc
    not_expired = %Ecto.DateTime{day: now.day, hour: now.hour, min: now.min,
                             month: now.month, sec: now.sec, year: now.year + 1}
    user = TestUtils.create_user(not_expired)

    conn = conn(:get, "/repos") |> TestUtils.sign_conn
    conn = put_session(conn, :user, %{auth_token: user.auth_token})
    conn = check_user(conn, %{})
    assert conn.assigns.user
  end
end