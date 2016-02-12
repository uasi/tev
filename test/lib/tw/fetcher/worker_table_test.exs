defmodule Tev.Tw.Fetcher.WorkerTableTest do
  use ExUnit.Case, async: true

  alias Tev.Tw.Fetcher.WorkerTable

  @timeline_id 1
  @enough_timeout_ms 1000

  setup do
    WorkerTable.clear
    :ok
  end

  test "check_in" do
    assert WorkerTable.check_in(@timeline_id) == true
  end

  test "check_out" do
    assert WorkerTable.check_out(@timeline_id) == true
  end

  test "unbalanced check ins and outs are ok" do
    assert WorkerTable.check_in(@timeline_id) == true
    assert WorkerTable.check_in(@timeline_id) == true
    assert WorkerTable.check_out(@timeline_id) == true
    assert WorkerTable.check_out(@timeline_id) == true
  end

  test "live_worker_exists? returns true if worker exists" do
    WorkerTable.check_in(@timeline_id)
    assert WorkerTable.live_worker_exists?(@timeline_id, @enough_timeout_ms) == true
  end

  test "live_worker_exists? returns false if worker exists but has timed out" do
    sleep_ms = 2
    timeout_ms = sleep_ms / 2
    WorkerTable.check_in(@timeline_id)
    :timer.sleep(sleep_ms)
    assert WorkerTable.live_worker_exists?(@timeline_id, timeout_ms) == false
  end

  test "live_worker_exists? returns false if worker has checked out" do
    WorkerTable.check_in(@timeline_id)
    WorkerTable.check_out(@timeline_id)
    assert WorkerTable.live_worker_exists?(@timeline_id, @enough_timeout_ms) == false
  end

  test "live_worker_exists? returns false if worker does not exist for timeline" do
    another_timeline_id = @timeline_id + 1
    WorkerTable.check_in(another_timeline_id)
    assert WorkerTable.live_worker_exists?(@timeline_id, @enough_timeout_ms) == false
  end
end
