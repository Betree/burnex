defmodule Burnex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :burnex,
      version: "1.0.2",
      elixir: "~> 1.5",
      description: "Elixir burner email (temporary address) detector",
      start_permanent: Mix.env == :prod,
      package: package(),
      deps: deps(),
      docs: [main: "Burnex"],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      {:ex_doc, "~> 0.11", only: :dev, runtime: false},
      {:earmark, "~> 0.1", only: :dev, runtime: false},
      {:excoveralls, "~> 0.8", only: :test},
      {:stream_data, "~> 0.1", only: :test}
    ]
  end

  defp package do
    [
     files: ["lib", "priv", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["Benjamin Piouffle"],
     licenses: ["MIT"],
     links: %{
       "GitHub" => "https://github.com/Betree/burnex",
       "Docs" => "https://hexdocs.pm/burnex"
     }
   ]
  end
end
