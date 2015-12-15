use Mix.Config

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
config :credo_server, CredoServer.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: "credo.inakalabs.com", port: 80],
  cache_static_manifest: "priv/static/manifest.json"

# Do not print debug messages in production
config :logger, level: :info

# If you are doing OTP releases, you need to instruct Phoenix to start the
# server for all endpoints, you can configure exactly which server to start per
# endpoint:
config :credo_server, CredoServer.Endpoint, server: true

# Finally import the config/prod.secret.exs
# which should be versioned separately.
import_config "prod.secret.exs"
