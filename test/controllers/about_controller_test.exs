defmodule CredoServer.AboutControllerTest do
  use Plug.Test
  alias CredoServer.{Router, TestUtils}
  use ExUnit.Case, async: true

  @router_opts Router.init([])

  test "show about page" do
    conn =
      conn(:get, "/about")
      |> TestUtils.sign_conn
      |> Router.call(@router_opts)

    assert conn.status == 200
  end
end
