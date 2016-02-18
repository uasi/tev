defmodule Tev.Plugs.AssignLocale do
  def init(opts), do: opts

  def call(conn, opts) do
    supported_locales = [default_locale | _] =
      Keyword.fetch!(opts, :supported_locales)
    locale = List.first(extract_accept_language(conn))
    if locale && locale in supported_locales do
      Plug.Conn.assign(conn, :locale, locale)
    else
      Plug.Conn.assign(conn, :locale, default_locale)
    end
  end

  # Adapted from http://code.parent.co/practical-i18n-with-phoenix-and-elixir/
  defp extract_accept_language(conn) do
    case conn |> Plug.Conn.get_req_header("accept-language") do
      [value|_] ->
        value
        |> String.replace(" ", "")
        |> String.split(",")
        |> Enum.map(&parse_language_option/1)
        |> Enum.sort(&(&1.quality >= &2.quality))
        |> Enum.map(&(&1.tag))
      _ ->
        []
    end
  end

  defp parse_language_option(string) do
    captures = ~r/^(?<tag>[\w\-]+)(?:;q=(?<quality>[\d\.]+))?$/i
    |> Regex.named_captures(string)

    quality = case Float.parse(captures["quality"] || "1.0") do
      {val, _} -> val
      _ -> 1.0
    end

    %{tag: captures["tag"], quality: quality}
  end
end
