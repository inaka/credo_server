defmodule CredoServer.UsersController do
  @moduledoc false

  import Plug.Conn
  import Ecto.Query
  alias CredoServer.User

  def active_users(conn) do
    users = User.active_users

    send_resp(conn, 200, "Active users: #{Enum.count(users)}")
  end
end
