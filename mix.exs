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
     deps: deps,
     dialyzer: dialyzer,
   ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Tev, []},
     applications: [:phoenix, :phoenix_html, :phoenix_pubsub, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :poolboy, :postgrex, :quantum, :ecto] ++ applications(Mix.env)]
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
      {:credo, "~> 0.3.0", only: [:dev, :test]},
      {:dialyxir, "~> 0.3.0", only: [:dev]},
      {:ex_machina, "~> 1.0", only: [:test]},
      {:extwitter, "~> 0.6.2"},
      {:gettext, "~> 0.11.0"},
      {:oauth, github: "tim/erlang-oauth", tag: "v1.5.0", override: true},
      {:phoenix, "~> 1.2.0"},
      {:phoenix_ecto, "~> 3.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_pubsub, "~> 1.0"},
      {:poolboy, "~> 1.5"},
      {:postgrex, "~> 0.11.0"},
      {:quantum, "~> 1.6"},
      {:scrivener_ecto, "~> 1.0"},
      {:timex, "~> 1.0"},
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
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end

  defp dialyzer do
    [
      flags: ~w(-Werror_handling -Wrace_conditions -Wunderspecs),
      plt_file: "_local.plt",
    ]
  end
end
