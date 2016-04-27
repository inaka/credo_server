use Mix.Config

# Configure your database
config :credo_server, CredoServer.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "credo_server_dev",
  hostname: "localhost",
  pool_size: 10

config :credo_server, :github_scope, "repo,user:email"
config :credo_server, :github_client_id, System.get_env("GITHUB_CLIENT_ID")
config :credo_server, :github_client_secret, System.get_env("GITHUB_CLIENT_SECRET")
config :credo_server, :github_user, System.get_env("GITHUB_USER")
config :credo_server, :github_password, System.get_env("GITHUB_PASSWORD")
config :credo_server, :webhook_url, System.get_env("WEBHOOK_URL")
config :credo_server, :secret_key_base, System.get_env("SECRET_KEY_BASE")
