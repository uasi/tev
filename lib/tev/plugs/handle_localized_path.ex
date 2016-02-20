defmodule Tev.Plugs.HandleLocalizedPath do
  @moduledoc """
  This plug handles localized path.

  If the first element of `conn.path_info` is a known locale, this plug assigns
  the locale to conn with two keys, `:locale` and `:path_locale`, and then
  update `conn.path_info` by removing the locale. Otherwise this plug does
  nothing.
  """

  import Plug.Conn, only: [assign: 3]

  def init(opts), do: opts

  def call(conn, _opts) do
    supported_locales = Gettext.known_locales(Tev.Gettext)
    case conn.path_info do
      [locale | rest] ->
        if locale in supported_locales do

          %{conn | path_info: rest}
          |> assign(:locale, locale)
          |> assign(:path_locale, locale)
        else
          conn
        end
      _ ->
        conn
    end
  end
end
