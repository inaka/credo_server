use Mix.Config

# Configure your database
config :credo_server, CredoServer.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASS"),
  database: System.get_env("DB_DATABASE"),
  hostname: System.get_env("DB_HOST"),
  pool_size: 10

config :credo_server, :github_scope, "repo,user:email"
config :credo_server, :github_client_id, System.get_env("GITHUB_CLIENT_ID")
config :credo_server, :github_client_secret, System.get_env("GITHUB_CLIENT_SECRET")
config :credo_server, :github_user, System.get_env("GITHUB_USER")
config :credo_server, :github_password, System.get_env("GITHUB_PASSWORD")
config :credo_server, :webhook_url, System.get_env("WEBHOOK_URL")
config :credo_server, :secret_key_base, System.get_env("SECRET_KEY_BASE")
config :credo_server, :egithub, :egithub
config :credo_server, :egithub_webhook, :egithub_webhook
