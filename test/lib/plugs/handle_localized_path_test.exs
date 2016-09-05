defmodule Tev.Plugs.HandleLocalizedPathTest do
  use ExUnit.Case, async: true

  def get_conn_through_plug(path, supported_locales) do
    path_info = String.split(path, "/", trim: true)
    %{Phoenix.ConnTest.build_conn | path_info: path_info}
    |> Tev.Plugs.HandleLocalizedPath.call(supported_locales: supported_locales)
  end

  test "it handles supported locale in path info" do
    conn = get_conn_through_plug("/en/foo/bar", ~w(en ja))
    assert conn.assigns[:locale] == "en"
    assert conn.assigns[:path_locale] == "en"
    assert conn.path_info == ~w(foo bar)
  end

  test "it does not handle unsupported locale in path info" do
    conn = get_conn_through_plug("/de/foo/bar", ~w(en ja))
    assert conn.assigns[:locale] == nil
    assert conn.assigns[:path_locale] == nil
    assert conn.path_info == ~w(de foo bar)

    conn = get_conn_through_plug("/", ~w(en ja))
    assert conn.assigns[:locale] == nil
    assert conn.assigns[:path_locale] == nil
    assert conn.path_info == ~w()
  end
end
