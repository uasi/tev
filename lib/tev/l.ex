defmodule Tev.L do
  @defmodule """
  A pretty-printing logger.

  ## Examples

      defmodule Foo do
        use Tev.L

        def foo do
          L.info("Info!")
          L.warn("Warn!", ["gistable_value", key: "inspectable_value"])
        end
      end

  Each optional parameter is stringified through `Tev.L.Gist.gist/1`.
  """

  defprotocol Gist do
    @fallback_to_any true
    def gist(data)
  end

  defimpl Gist, for: Tuple do
    def gist({key, value}) when is_atom(key), do: "#{key}=#{inspect value}"
    def gist(tuple), do: inspect(tuple)
  end
  defimpl Gist, for: Any do
    def gist(data), do: inspect(data)
  end

  defmacro __using__([]) do
    quote do
      require Logger
      require unquote(__MODULE__)
      alias unquote(__MODULE__), as: L
    end
  end

  defmacro debug(message, params \\ []), do: log(:debug, message, params)
  defmacro info(message, params \\ []), do: log(:info, message, params)
  defmacro warn(message, params \\ []), do: log(:warn, message, params)
  defmacro error(message, params \\ []), do: log(:error, message, params)

  defp log(level, message, params) do
    quote do
      Logger.unquote(level)(fn ->
        unquote(__MODULE__).format(
          __MODULE__, self, unquote(message), unquote(params)
        )
      end)
    end
  end

  def format(nil, pid, message, params) do
    format(:"Elixir.(nil)", pid, message, params)
  end
  def format(module, pid, message, params) do
    "Elixir." <> abbrev_mod = Atom.to_string(module)
    gists =
      params
      |> Enum.map(&Gist.gist/1)
      |> Enum.join(" ")
    case gists do
      "" -> "#{abbrev_mod} #{inspect pid}: #{message}"
      _  -> "#{abbrev_mod} #{inspect pid}: #{message}; #{gists}"
    end
  end
end
