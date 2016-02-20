defmodule Tev.Plugs.ConfigureGettext do

  def init(opts), do: opts

  def call(conn, _opts) do
    locale = conn.assigns[:locale]
    if locale in Gettext.known_locales(Tev.Gettext) do
      Gettext.put_locale(Tev.Gettext, locale)
      conn
    else
      conn
    end
  end
end
