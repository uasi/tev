defmodule Tev.Plugs.AssignLocaleTest do
  use ExUnit.Case, async: true

  alias Tev.Plugs.AssignLocale

  defp get_assigned_locale(header_value, supported_locales) do
    Phoenix.ConnTest.build_conn
    |> Plug.Conn.put_req_header("accept-language", header_value)
    |> AssignLocale.call(supported_locales: supported_locales)
    |> Map.from_struct
    |> get_in([:assigns, :locale])
  end

  test "it assigns locale extracted from accept-language header" do
    assert get_assigned_locale("en", ~w(ja en)) == "en"
    assert get_assigned_locale("en", ~w(en ja)) == "en"
    assert get_assigned_locale("de", ~w(en ja)) == "en"
    assert get_assigned_locale("en, ja, de", ~w(ja en)) == "en"
    assert get_assigned_locale("ja;q=0.9, en", ~w(ja en)) == "en"
  end
end
