use Mix.Config

# Do not print debug messages in production
config :logger, level: :info

config :tev, Tev.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: System.get_env("APP_HOSTNAME"), port: 80],
  secret_key_base: System.get_env("SECRET_KEY_BASE")

if System.get_env("HTTPS_REVERSE_PROXY") == "1" do
  config :tev, Tev.Endpoint,
    url: [scheme: "https", host: System.get_env("APP_HOSTNAME"), port: 443]
end

config :tev, Tev.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: 20
