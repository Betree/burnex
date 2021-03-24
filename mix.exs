defmodule Burnex.Mixfile do
  use Mix.Project

  @source_url "https://github.com/Betree/burnex"
  @version String.trim(File.read!("VERSION"))

  def project do
    [
      app: :burnex,
      version: @version,
      elixir: "~> 1.7",
      description: "Elixir burner email (temporary address) detector",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        credo: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.github": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        dialyzer: :test
      ],
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
      {:dns, "~> 2.2.0"},

      # Dev
      {:credo, "~> 1.5.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:eliver, "~> 2.0.0", only: :dev},

      # Testing
      {:excoveralls, "~> 0.10", only: :test, runtime: false},
      {:stream_data, "~> 0.1", only: :test}
    ]
  end

  defp package do
    [
      files: [
        "lib",
        "priv/burner-email-providers",
        "mix.exs",
        "README.md",
        "CHANGELOG.md",
        "LICENSE",
        "VERSION"
      ],
      maintainers: ["Benjamin Piouffle"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "#{@source_url}/blob/master/CHANGELOG.md",
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      main: "Burnex",
      api_reference: false,
      homepage_url: @source_url,
      source_ref: @version,
      source_url: @source_url,
      extras: ["CHANGELOG.md"]
    ]
  end
end
