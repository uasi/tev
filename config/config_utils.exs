defmodule Tev.ConfigUtils do
  def get_int_env(name, default \\ nil) do
    string =
      (System.get_env(name) || "")
      |> String.replace("_", "")
    case Integer.parse(string) do
      {i, _} -> i
      :error -> default
    end
  end
end
