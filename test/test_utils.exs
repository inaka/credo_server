defmodule CredoServer.TestUtils do
  use Plug.Test
  alias CredoServer.{Repo, User}

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

  def create_user() do
    now = Ecto.DateTime.utc
    not_expired = %Ecto.DateTime{day: now.day, hour: now.hour, min: now.min,
                             month: now.month, sec: now.sec, year: now.year + 1}
    create_user(not_expired)
  end
  def create_user(auth_expires) do
    user_info = %{username: "alemata",
                  name: "name",
                  github_token: "github_token_example",
                  email: "email@email.com",
                  auth_token: "validtoken",
                  auth_expires: auth_expires}
    user_changeset = User.changeset(%User{}, user_info)

    {:ok, user} = Repo.insert(user_changeset)
    user
  end

  def login_user(conn) do
    now = Ecto.DateTime.utc
    not_expired = %Ecto.DateTime{day: now.day, hour: now.hour, min: now.min,
                             month: now.month, sec: now.sec, year: now.year + 1}
    user = create_user(not_expired)
    conn = assign(conn, :user, %{auth_token: user.auth_token})
    conn
  end
  def login_user(conn, user) do
    conn = assign(conn, :user, %{auth_token: user.auth_token})
    conn
  end
end
