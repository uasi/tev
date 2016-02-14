defmodule Tev.Utils do
  @spec string_to_any_of_atoms(binary, [atom]) :: {:ok, atom} | :error
  def string_to_any_of_atoms(string, atoms) do
    try do
      atom = String.to_existing_atom(string)
      if atom in atoms, do: {:ok, atom}, else: :error
    rescue
      ArgumentError -> :error
    end
  end

  def elapsed_since_datetime(datetime, type \\ :timestamp) do
    datetime
    |> Ecto.DateTime.to_erl
    |> Timex.Date.from
    |> Timex.Date.to_timestamp
    |> Timex.Time.elapsed(type)
  end
end
