defmodule Tev.UtilsTest do
  use ExUnit.Case, async: true

  alias Tev.Utils

  test "string_to_any_of_atoms" do
    atoms = ~w(foo bar baz)a
    assert Utils.string_to_any_of_atoms("foo", atoms) == {:ok, :foo}
    assert Utils.string_to_any_of_atoms("qux", atoms) == :error
  end
end
