defmodule Earlgrey.MixProject do
  use Mix.Project

  def project do
    [
      app: :earlgrey,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Earlgrey.Application, {}},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, "~> 0.4"},
      {:httpoison, "~> 1.8"},
      {:floki, "~> 0.31.0"}
    ]
  end
end
