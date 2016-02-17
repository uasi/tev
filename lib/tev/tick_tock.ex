defmodule Tev.TickTock do
  use Tev.L

  @spec tick :: integer
  def tick do
    t = monotonic_time
    Process.put(__MODULE__, t)
    t
  end

  @spec tock :: integer
  def tock do
    case Process.get(__MODULE__) do
      nil ->
        L.warn("tock called before tick")
        0
      t ->
        monotonic_time - t
    end
  end

  defp monotonic_time do
    :erlang.monotonic_time(:milli_seconds)
  end
end
