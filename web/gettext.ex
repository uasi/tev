defmodule Tev.Gettext do
  @moduledoc """
  A module providing Internationalization with a gettext-based API.

  By using [Gettext](http://hexdocs.pm/gettext),
  your module gains a set of macros for translations, for example:

      import Tev.Gettext

      # Simple translation
      gettext "Here is the string to translate"

      # Plural translation
      ngettext "Here is the string to translate",
               "Here are the strings to translate",
               3

      # Domain-based translation
      dgettext "errors", "Here is the error message to translate"

  See the [Gettext Docs](http://hexdocs.pm/gettext) for detailed usage.
  """
  use Gettext, otp_app: :tev

  def default_locale do
    Application.get_env(:tev, Tev.Gettext)[:default_locale] || "en"
  end

  def find_locale(language_tag) do
    [language | _] =
      language_tag
      |> String.downcase
      |> String.split("-", parts: 2)
    Gettext.known_locales(__MODULE__)
    if language in Gettext.known_locales(__MODULE__) do
      language
    else
      nil
    end
  end
end
