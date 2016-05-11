defmodule CredoServer.AuthPlugTest do
  use ExUnit.Case
  use Plug.Test
  import CredoServer.Plug.Auth
  alias CredoServer.TestUtils

  setup do
    Ecto.Adapters.SQL.restart_test_transaction(CredoServer.Repo)
    :ok
  end

  test "not logged in user" do
    conn =
      conn(:get, "/repos")
      |> TestUtils.sign_conn()
      |> check_user(%{})
    assert conn.status == 302
    assert hd(get_resp_header(conn, "location")) == "/auth"
    refute conn.assigns[:user]
  end

  test "logged with an invalid token" do
    conn =
      conn(:get, "/repos")
      |> TestUtils.sign_conn
      |> put_session(:user, %{auth_token: "invalidtoken"})
      |> check_user(%{})

    assert conn.status == 302
    assert hd(get_resp_header(conn, "location")) == "/auth"
    refute conn.assigns[:user]
  end

  test "logged with an expired token" do
    now = Ecto.DateTime.utc
    expired = %Ecto.DateTime{day: now.day, hour: now.hour, min: now.min,
                             month: now.month, sec: now.sec, year: now.year - 1}
    user = TestUtils.create_user(expired)

    conn =
      conn(:get, "/repos")
      |> TestUtils.sign_conn
      |> put_session(:user, %{auth_token: user.auth_token})
      |> check_user(%{})

    assert conn.status == 302
    assert hd(get_resp_header(conn, "location")) == "/auth"
    refute conn.assigns[:user]
  end

  test "logged with a valid token" do
    now = Ecto.DateTime.utc
    not_expired = %Ecto.DateTime{day: now.day, hour: now.hour, min: now.min,
                             month: now.month, sec: now.sec, year: now.year + 1}
    user = TestUtils.create_user(not_expired)

    conn =
      conn(:get, "/repos")
      |> TestUtils.sign_conn
      |> put_session(:user, %{auth_token: user.auth_token})
      |> check_user(%{})

    assert conn.assigns.user
  end
end
