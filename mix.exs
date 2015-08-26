defmodule Money.Mixfile do
  use Mix.Project

  def project do
    [app: :money,
     version: "0.0.1-dev",
     elixir: "~> 1.0",
     deps: [],
     source_url: "https://github.com/liuggio/money",
     docs: fn ->
       {ref, 0} = System.cmd("git", ["rev-parse", "--verify", "--quiet", "HEAD"])
       [source_ref: ref, readme: "README.md"]
     end,
     description: description,
     package: package]
  end


  def application do
    []
  end


  defp description do
    """
    Elixir library for working with Money safer, easier, and fun, is an interpretation of the Fowler's Money pattern in fun.prog.
    """
  end

  defp package do
    [contributors: ["Giulio De Donato"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/liuggio/money"}]
  end
end
