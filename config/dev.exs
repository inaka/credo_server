use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
config :credo_server, CredoServer.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  watchers: []

# Watch static and templates for browser reloading.
config :credo_server, CredoServer.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :credo_server, CredoServer.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "credo_server_dev",
  hostname: "localhost",
  pool_size: 10

#TODO move to os env variables
config :credo_server, :github_client_id, "4818aa2f7fbc1234a086"
config :credo_server, :github_client_secret, "805bca159c281dcda265eb9786d16712ba0efca5"
config :credo_server, :github_scope, "repo,user:email"
config :credo_server, :webhook_url, "http://1e9f5a98.ngrok.io/webhook"
