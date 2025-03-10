if File.exists?("blend/premix.exs") do
  Code.compile_file("blend/premix.exs")
end

defmodule Money.Mixfile do
  use Mix.Project

  @version "1.14.0"
  @github_url "https://github.com/elixirmoney/money"

  def project do
    [
      app: :money,
      aliases: aliases(),
      name: "Money",
      version: @version,
      elixir: "~> 1.11",
      deps: deps(),
      docs: fn ->
        [
          main: "readme",
          source_ref: "v#{@version}",
          source_url: @github_url,
          canonical: "http://hexdocs.pm/money",
          source_url: @github_url,
          extras: ["README.md", "CHANGELOG.md", "CONTRIBUTING.md", "LICENSE.md"]
        ]
      end,
      description: description(),
      package: package(),
      preferred_cli_env: [check: :test],
      dialyzer: [plt_add_apps: [:ecto, :phoenix_html, :decimal]]
    ]
    |> Keyword.merge(maybe_lockfile_option())
  end

  def application do
    []
  end

  defp deps do
    [
      # Soft dependencies
      {:ecto, "~> 2.1 or ~> 3.0", optional: true},
      {:phoenix_html, "~> 2.0 or ~> 3.0 or ~> 4.0", optional: true},
      {:decimal, "~> 1.2 or ~> 2.0", optional: true},

      # Code style and analyzers
      # Credo 1.7.7 requires Elixir 1.13+
      {:credo, "== 1.7.6", only: [:dev, :test], runtime: false, optional: true},
      {:dialyxir, "~> 1.4.2", only: [:dev, :test], runtime: false, optional: true},

      # Docs
      {:ex_doc, "~> 0.21", only: [:dev, :docs]},

      # Needed to test diffent Decimal versions
      {:blend, "~> 0.3.0", only: :dev}
    ]
  end

  defp maybe_lockfile_option do
    case System.get_env("MIX_LOCKFILE") do
      nil -> []
      "" -> []
      lockfile -> [lockfile: lockfile]
    end
  end

  defp description do
    """
    Elixir library for working with Money safer, easier, and fun, is an
    interpretation of the Fowler's Money pattern in fun.prog.
    """
  end

  defp package do
    [
      maintainers: ["Petr Stepchenko", "Giulio De Donato", "Andrew Timberlake"],
      contributors: ["Petr Stepchenko", "Giulio De Donato", "Andrew Timberlake"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "#{@github_url}/blob/master/CHANGELOG.md",
        "GitHub" => @github_url
      }
    ]
  end

  defp aliases do
    [
      check: ["format --check-formatted", "credo --strict", "test", "dialyzer"]
    ]
  end
end
