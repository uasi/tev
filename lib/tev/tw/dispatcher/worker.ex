defmodule Tev.Tw.Dispatcher.Worker do
  @moduledoc false

  use GenServer

  require Logger

  alias Tev.Repo
  alias Tev.Tw.Fetcher

  def start_link([]) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    Logger.debug("#{__MODULE__} #{inspect self}: started")
    {:ok, nil}
  end

  def run(pid, user) do
    GenServer.call(pid, {:run, user})
  end

  def handle_call({:run, user}, _from, _state) do
    Repo.preload(user, :timelines).timelines
    |> Enum.map(&Fetcher.fetch(user, &1))
    {:reply, :ok, nil}
  end
end
