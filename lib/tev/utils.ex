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
end
