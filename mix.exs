defmodule CredoServer.Mixfile do
  use Mix.Project

  def project do
    [app: :credo_server,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: ["lib", "web"],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:egithub, :httpoison, :postgrex,
                    :ecto, :tentacat, :plug, :credo],
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
     {:credo, "~> 0.3", only: [:dev, :test]},
     {:egithub, github: "inaka/erlang-github"}
   ]
  end
end
