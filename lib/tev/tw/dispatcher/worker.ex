defmodule Tev.Tw.Dispatcher.Worker do
  @moduledoc false

  use GenServer

  require Logger

  alias Tev.HomeTimeline
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
    timeline = HomeTimeline.get_or_insert_by_user_id(user.id)
    Fetcher.fetch(user, timeline)
    {:reply, :ok, nil}
  end
end
