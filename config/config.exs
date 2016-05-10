# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :credo_server, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:credo_server, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

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

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env}.exs"
