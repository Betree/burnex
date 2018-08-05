defmodule Burnex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :burnex,
      version: "1.0.4",
      elixir: "~> 1.6.6",
      description: "Elixir burner email (temporary address) detector",
      start_permanent: Mix.env == :prod,
      package: package(),
      deps: deps(),
      docs: [main: "Burnex"],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      dialyzer: [remove_defaults: [:unknown]]
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      # Dev
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.3", only: :dev, runtime: false},
      {:earmark, "~> 0.1", only: :dev, runtime: false},
      {:ex_doc, "~> 0.11", only: :dev, runtime: false},

      # Testing
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
