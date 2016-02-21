# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

Code.load_file("config_utils.exs", __DIR__)
alias Tev.ConfigUtils, as: Utils

config :tev,
  max_timeline_tweets: 1000

config :tev, Tev.Tw.Dispatcher,
  timeout_ms: Utils.get_int_env("DISPATCHER_TIMEOUT_MS", 10_000),
  pool_size: Utils.get_int_env("DISPATCHER_POOL_SIZE", 5),
  max_overflow: Utils.get_int_env("DISPATCHER_MAX_OVERFLOW", 1)

# Note: Each worker makes one to about ten API calls, depending how many tweets
# are available in a timeline.
config :tev, Tev.Tw.Fetcher,
  timeout_ms: Utils.get_int_env("FETCHER_TIMEOUT_MS", 120_000),
  pool_size: Utils.get_int_env("FETCHER_POOL_SIZE", 5),
  max_overflow: Utils.get_int_env("FETCHER_MAX_OVERFLOW", 1)

# Configures the endpoint
config :tev, Tev.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "fksAPCQfSCjXk9vau7i1/DLiT7LNarkYFbFGoIFjg4BG4RSNR2J8pOqyG1bEkjsa",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Tev.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :tev, Tev.Gettext,
  default_locale: "en"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
