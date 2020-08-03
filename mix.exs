defmodule Burnex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :burnex,
      version: String.trim(File.read!("VERSION")),
      elixir: "~> 1.7",
      description: "Elixir burner email (temporary address) detector",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: [main: "Burnex"],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      dialyzer: [
        remove_defaults: [:unknown],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      # Dev
      {:credo, "~> 1.4.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.3", only: :dev, runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:eliver, "~> 2.0.0", only: :dev},

      # Testing
      {:excoveralls, "~> 0.10", only: :test},
      {:stream_data, "~> 0.1", only: :test}
    ]
  end

  defp package do
    [
      files: ["lib", "priv/burner-email-providers", "mix.exs", "README.md", "LICENSE", "VERSION"],
      maintainers: ["Benjamin Piouffle"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/Betree/burnex",
        "Docs" => "https://hexdocs.pm/burnex"
      }
    ]
  end
end
