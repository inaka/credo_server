defmodule CredoServer.Mixfile do
  use Mix.Project

  def project do
    [app: :credo_server,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: ["lib", "web"],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test,
                         "coveralls.detail": :test,
                         "coveralls.html": :test],
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:poison, :eex, :cowboy, :egithub, :httpoison, :postgrex,
                    :ecto, :tentacat, :plug, :credo, :secure_random],
     mod: {CredoServer, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:cowboy, "~> 1.0.0"},
     {:plug, "~> 1.0"},
     {:poison, "~> 1.5.2"},
     {:httpoison, "~> 0.8.0"},
     {:postgrex, ">= 0.0.0"},
     {:ecto, "~> 1.1.5"},
     {:tentacat, "~> 0.2"},
     {:secure_random, "~> 0.2"},
     {:credo, git: "https://github.com/rrrene/credo", tag: "release-0.4.0"},
     {:egithub, "~> 0.2.6"},
     {:excoveralls, "~> 0.4", only: :test},
     {:exvcr, "~> 0.7", only: :test},
     {:exrm, "~> 1.0.5"}
   ]
  end
end
