defmodule Tev.Tw.Fetcher do
  @moduledoc """
  Fetches all available tweets in a timeline and pass them to the collector.
  """

  alias Tev.HomeTimeline
  alias Tev.Tw.Fetcher.Worker
  alias Tev.User

  # Note: Each worker makes one to about ten API calls, depending how many
  # tweets are available in the given timeline.
  @timeout_ms 60_000
  @pool_size 5
  @max_overflow 1

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
