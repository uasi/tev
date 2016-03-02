defmodule Tev.Tw.Dispatcher do
  @moduledoc """
  Dispatches fetch request to fetcher.
  """

  use Tev.L

  alias Tev.Repo
  alias Tev.Tw.Dispatcher.Worker
  alias Tev.User

  @timeout_ms Application.get_env(:tev, __MODULE__)[:timeout_ms]
  @pool_size Application.get_env(:tev, __MODULE__)[:pool_size]
  @max_overflow Application.get_env(:tev, __MODULE__)[:max_overflow]

  @doc """
  Dispatches fetch requests for all users to fetcher.
  """
  @spec dispatch_all :: :ok
  def dispatch_all do
    L.info("dispatch all")
    spawn fn ->
      Repo.all(User)
      |> Enum.each(&run_pooled_worker/1)
    end
    :ok
  end

  @doc """
  Dispatches fetch request to fetcher.
  """
  @spec dispatch(User.t) :: :ok
  def dispatch(user) do
    spawn fn ->
      run_pooled_worker(user)
    end
    :ok
  end

  defp run_pooled_worker(user) do
    :poolboy.transaction(
      pool_name,
      fn(pid) -> Worker.run(pid, user) end,
      @timeout_ms
    )
  end

  @doc """
  Retruns pool spec for `Tev.Tw.Dispatcher.Worker`.
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
    :tw_dispatcher_worker_pool
  end
end
