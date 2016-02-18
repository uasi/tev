defmodule Tev.LocalizedPathHelpers do
  @base_helpers Tev.Router.Helpers

  defmacro __using__([]) do
    quote do
      require unquote(__MODULE__)
      import unquote(__MODULE__), except: [get_locale_prefix: 1]
    end
  end

  defmacro path_to(conn_or_endpoint, name, action, params \\ []) do
    localize(conn_or_endpoint, name, "path", action, params)
  end

  defmacro url_to(conn_or_endpoint, name, action, params \\ []) do
    localize(conn_or_endpoint, name, "url", action, params)
  end

  defp localize(conn_or_endpoint, name, suffix, action, params) do
    fun = "#{name}_#{suffix}" |> String.to_existing_atom
    quote do
      c = unquote(conn_or_endpoint)
      Kernel.<>(
        unquote(__MODULE__).get_path_prefix(c),
        unquote(@base_helpers).unquote(fun)(c, unquote(action), unquote(params))
      )
    end
  end

  def get_path_prefix(%Plug.Conn{assigns: %{path_locale: locale}}) when is_binary(locale) do
    "/#{locale}"
  end
  def get_path_prefix(_) do
    ""
  end
end
