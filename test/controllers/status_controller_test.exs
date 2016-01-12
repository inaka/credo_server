defmodule CredoServer.StatusControllerTest do
  use CredoServer.ConnCase

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "shows status", %{conn: conn} do
    conn = get conn, status_path(conn, :show)
    assert json_response(conn, 200) == %{"status" => "OK"}
  end

end
