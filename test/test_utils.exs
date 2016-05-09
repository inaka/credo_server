defmodule CredoServer.TestUtils do
  use Plug.Test
  alias CredoServer.Repo
  alias CredoServer.User

  @default_opts [
    store: :cookie,
    key: "foobar",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt",
    log: false
  ]

  @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))

  def sign_conn(conn) do
    put_in(conn.secret_key_base, String.duplicate("abcdef0123456789", 8))
    |> Plug.Session.call(@signing_opts)
    |> fetch_session
  end

  def create_user(auth_expires) do
    user_info = %{username: "username",
                  name: "name",
                  github_token: "token",
                  email: "email@email.com",
                  auth_token: "validtoken",
                  auth_expires: auth_expires}
    user_changeset = User.changeset(%User{}, user_info)

    {:ok, user} = Repo.insert(user_changeset)
    user
  end
end
