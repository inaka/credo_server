defmodule CredoServer.Mixfile do
  use Mix.Project

  def project do
    [app: :credo_server,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  # Configuration for the OTP application.
  def application do
    [mod: {CredoServer, []},
     applications: [
      :phoenix,
      :phoenix_html,
      :cowboy,
      :logger,
      :phoenix_ecto,
      :postgrex,
      :tentacat
     ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  defp deps do
    [{:phoenix, "~> 1.0.4"},
     {:phoenix_ecto, "~> 1.1"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.1"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:cowboy, "~> 1.0"},
     {:tentacat, "~> 0.3.1"},
     {:secure_random, "~> 0.2"}
   ]
  end

  # Aliases are shortcut or tasks specific to the current project.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"]]
  end
end
