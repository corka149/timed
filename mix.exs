defmodule Timed.MixProject do
  use Mix.Project

  def project do
    [
      app: :timed,
      version: "1.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.20.2"},
      {:earmark, "~> 1.3"},
    ]
  end

  # Run "mix escript.build" to build the cli
  defp escript do
    [
      main_module: Timed.Cli
    ]
  end
end
