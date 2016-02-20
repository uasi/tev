defmodule Tev.GettextTest do
  use ExUnit.Case, async: true

  test "default_locale returns default locale" do
    default_locale = Application.get_env(:tev, Tev.Gettext)[:default_locale]
    assert default_locale != nil

    assert Tev.Gettext.default_locale == default_locale
  end

  # `Tev.Gettext.find_locale/1` depends on this because it is so poor that it
  # cannot recogize full-blown IFTF language tags.
  test "each known locale does not contain any subtags other than language subtag" do
    assert Gettext.known_locales(Tev.Gettext) |> Enum.all?(&(&1 =~ ~r/^[a-z]{2}$/))
  end

  test "find_locale finds a known locale that matches with the given language tag" do
    unknown_locale = "xx"
    assert !(unknown_locale in Gettext.known_locales(Tev.Gettext))
    assert "en" in Gettext.known_locales(Tev.Gettext)

    assert Tev.Gettext.find_locale("en") == "en"
    assert Tev.Gettext.find_locale("en-US") == "en"
    assert Tev.Gettext.find_locale(unknown_locale) == nil
  end
end
