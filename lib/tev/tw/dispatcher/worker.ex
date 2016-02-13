defmodule Tev.Tw.Dispatcher.Worker do
  @moduledoc false

  use GenServer
  use Tev.L

  alias Tev.Repo
  alias Tev.Timeline
  alias Tev.Tw.Fetcher
  alias Tev.Tw.Fetcher.WorkerTable

  def start_link([]) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    L.debug("started")
    {:ok, nil}
  end

  def run(pid, user) do
    GenServer.call(pid, {:run, user})
  end

  def handle_call({:run, user}, _from, _state) do
    timeout_ms = Application.get_env(:tev, Fetcher)[:timeout_ms]
    Repo.preload(user, :timelines).timelines
    |> Enum.each(&try_fetch(user, &1, timeout_ms))
    {:reply, :ok, nil}
  end

  defp try_fetch(user, timeline, timeout_ms) do
    cond do
      Timeline.recently_collected?(timeline) ->
        L.debug("skipping timeline (recently collected)", [user, timeline])
      WorkerTable.live_worker_exists?(timeline.id, timeout_ms) ->
        L.debug("skipping timeline (worker is running)", [user, timeline])
      true ->
        Fetcher.fetch(user, timeline)
    end
  end
end
