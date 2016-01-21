use Mix.Config

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
#
# You should also configure the url host to something
# meaningful, we use this information when generating URLs.
#
# Finally, we also include the path to a manifest
# containing the digested version of static files. This
# manifest is generated by the mix phoenix.digest task
# which you typically run after static files are built.
config :tev, Tev.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: "tev.opts.io", port: 80]

# Do not print debug messages in production
config :logger, level: :info

config :tev, Tev.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :tev, Tev.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: 20
