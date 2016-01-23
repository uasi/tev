defmodule Tev do
  use Application

  alias Tev.TwitterAuth

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    TwitterAuth.initialize

    children = [
      supervisor(Tev.Endpoint, []),
      supervisor(Tev.Repo, []),
      worker(Tev.Tw.Collector, []),
      Tev.Tw.Dispatcher.pool_spec,
      Tev.Tw.Fetcher.pool_spec,
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tev.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Tev.Endpoint.config_change(changed, removed)
    :ok
  end
end
