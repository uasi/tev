defmodule Tev.Tw.Fetcher.WorkerTable do
  @table :tev_tw_fetcher_worker_table

  @spec initialize :: :ok
  def initialize do
    :ets.new(@table, [:set, :public, :named_table])
    :ok
  end

  @spec clear :: true
  def clear do
    :ets.delete_all_objects(@table)
  end

  @spec check_in(integer) :: true
  def check_in(timeline_id) do
    :ets.insert(@table, {timeline_id, System.monotonic_time(:milli_seconds)})
  end

  @spec check_out(integer) :: true
  def check_out(timeline_id) do
    :ets.delete(@table, timeline_id)
  end

  @spec live_worker_exists?(integer, integer) :: boolean
  def live_worker_exists?(timeline_id, worker_timeout_ms) do
    case :ets.lookup(@table, timeline_id) do
      [{_timeline_id, clocked_in_at}] ->
        clocked_in_at + worker_timeout_ms > System.monotonic_time(:milli_seconds)
      _ ->
        false
    end
  end
end
