defmodule Post2Slack.MixProject do
  use Mix.Project

  def project do
    [
      app: :post2slack,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.html": :test],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: mod(Mix.env())
    ]
  end

  defp mod(:test), do: []
  defp mod(_), do: {Post2Slack.Application, []}

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.4"},
      {:plug, "~> 1.6"},
      {:httpoison, "~> 1.3"},
      {:poison, "~> 4.0", override: true},
      {:joken, "~> 1.5"},
      {:jose, "~> 1.8"},
      {:distillery, "~> 2.0"},
      {:mock, "~> 0.3.2", only: [:test]},
      {:excoveralls, "~> 0.10.0", only: [:test]}
    ]
  end
end
