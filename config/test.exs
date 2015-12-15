use Mix.Config

config :credo_server, CredoServer.Endpoint,
  http: [port: 4001],
  server: true

config :logger, level: :warn

# Configure your database
config :credo_server, CredoServer.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "credo_server_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
