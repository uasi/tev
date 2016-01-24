defmodule Tev.Mixfile do
  use Mix.Project

  def project do
    [app: :tev,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Tev, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :poolboy, :postgrex, :quantum] ++ applications(Mix.env)]
  end

  def applications(:test), do: [:ex_machina]
  def applications(_),     do: []

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:credo, "~> 0.2.0", only: [:dev, :test]},
      {:ex_machina, "~> 0.6.1", only: [:test]},
      {:extwitter, github: "uasi/extwitter", branch: "tweet-extended-entities"},
      {:gettext, "~> 0.9"},
      {:oauth, github: "tim/erlang-oauth", tag: "v1.5.0", override: true},
      {:phoenix, "~> 1.1.0"},
      {:phoenix_ecto, "~> 2.0"},
      {:phoenix_html, "~> 2.3"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:poolboy, "~> 1.5"},
      {:postgrex, "~> 0.10.0"},
      {:quantum, "~> 1.6"},
   ]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"]]
  end
end
