defmodule CredoServer.Mixfile do
  use Mix.Project

  def project do
    [app: :credo_server,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:logger],
     mod: {CredoServer, []}]
  end

  defp deps do
    []
  end
end
