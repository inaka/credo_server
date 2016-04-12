defmodule CredoServer.Plug.AddSecretKey do
  @moduledoc false

  def add_secret_key(conn, _opts)  do
    put_in(conn.secret_key_base,
           Application.get_env(:credo_server, :secret_key_base))
  end
end
