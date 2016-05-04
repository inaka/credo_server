use Mix.Config

# Configure your database
config :credo_server, CredoServer.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "credo_server_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :credo_server, :github_scope, "repo,user:email"
config :credo_server, :github_client_id, System.get_env("GITHUB_CLIENT_ID")
config :credo_server, :github_client_secret, System.get_env("GITHUB_CLIENT_SECRET")
config :credo_server, :github_user, "git_user"
config :credo_server, :github_password, "git_pass"
config :credo_server, :webhook_url, System.get_env("WEBHOOK_URL")
config :credo_server, :secret_key_base, System.get_env("SECRET_KEY_BASE")
