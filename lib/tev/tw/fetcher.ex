defmodule Tev.Tw.Fetcher do
  @moduledoc """
  Fetches all available tweets in a timeline and pass them to the collector.
  """

  alias Tev.HomeTimeline
  alias Tev.Tw.Fetcher.Worker
  alias Tev.User

  @timeout_ms Application.get_env(:tev, __MODULE__)[:timeout_ms]
  @pool_size Application.get_env(:tev, __MODULE__)[:pool_size]
  @max_overflow Application.get_env(:tev, __MODULE__)[:max_overflow]

  @doc """
  Fetches all available tweets in a timeline and pass them to the collector.
  """
  @spec fetch(User.t, HomeTimeline.t) :: :ok
  def fetch(user, timeline) do
    spawn fn ->
      :poolboy.transaction(
        pool_name,
        fn(pid) -> Worker.run(pid, user, timeline) end,
        @timeout_ms
      )
    end
    :ok
  end

  @doc """
  Returns pool spec for `Tev.Tw.Fetcher.Worker`.
  """
  @spec pool_spec :: term
  def pool_spec do
    :poolboy.child_spec(pool_name, pool_config, [])
  end

  defp pool_config do
    [
      {:name, {:local, pool_name}},
      {:worker_module, Worker},
      {:size, @pool_size},
      {:max_overflow, @max_overflow},
    ]
  end

  defp pool_name do
    :tw_fetcher_worker_pool
  end
end
