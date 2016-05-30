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
config :credo_server, :github_client_id, "client_id"
config :credo_server, :github_client_secret, "client_secret"
config :credo_server, :github_user, "git_user"
config :credo_server, :github_password, "git_pass"
config :credo_server, :webhook_url, "http://62f72c52.ngrok.io/webhook"
config :credo_server, :secret_key_base, "zAAaH+c/OuERubfkgdF8NV4zHfkHIPijhAP1mCXm2saym7TBVz1DqrooauC/dHu8"
config :credo_server, :session_signing_salt, "BseWFusf"
config :credo_server, :session_encryption_salt, "pdCvsICN"
config :credo_server, :egithub, CredoServer.EgithubAdapter
config :credo_server, :egithub_webhook, CredoServer.EgithubAdapter
