defmodule Tev.EctoType.Tag do
  @moduledoc """
  Provides tag type, a.k.a. enum, tagged union, variants, etc.

  A tag is represented as an atom in Elixir, and stored as a value of certain
  type in the database.
  """

  @default_type :integer

  defmacro deftag(module, type \\ @default_type, mapping) do
    quote do
      defmodule unquote(module) do
        use unquote(__MODULE__), type: unquote(type), mapping: unquote(mapping)
      end
    end
  end

  defmacro __using__([]) do
    quote do
      import unquote(__MODULE__), only: [deftag: 2, deftag: 3]
    end
  end

  defmacro __using__(opts) do
    type = Keyword.get(opts, :type, @default_type)
    mapping = Keyword.fetch!(opts, :mapping)
    if length(mapping) == 0 do
      raise ArgumentError
    end

    quote do
      unquote(typespec(mapping))
      unquote(def_type(type))
      unquote(def_cast(mapping))
      unquote(def_load(mapping))
      unquote(def_dump(mapping))
      unquote(def_tags(mapping))
    end
  end

  defp typespec(mapping) do
    tags = Keyword.keys(mapping)
    tag_union =
      tags
      |> Enum.slice(0..-2)
      |> List.foldr(List.last(tags), fn tag, acc ->
        quote do
          unquote(tag) | unquote(acc)
        end
      end)

    quote do
      @type t :: unquote(tag_union)
    end
  end

  defp def_type(type) do
    quote do
      def type, do: unquote(type)
    end
  end

  defp def_cast(mapping) do
    values = Enum.map(mapping, &elem(&1, 1))
    defs = for {tag, v} <- mapping do
      quote do
        def cast(unquote(tag)), do: {:ok, unquote(v)}
      end
    end

    quote do
      unquote(defs)
      def cast(v) when v in unquote(values), do: {:ok, v}
      def cast(_), do: :error
    end
  end

  defp def_load(mapping) do
    defs = for {tag, v} <- mapping do
      quote do
        def load(unquote(v)), do: {:ok, unquote(tag)}
      end
    end

    quote do
      unquote(defs)
      def load(_), do: :error
    end
  end

  defp def_dump(mapping) do
    values = Enum.map(mapping, &elem(&1, 1))
    quote do
      def dump(v) when v in unquote(values), do: {:ok, v}
      def dump(_), do: :error
    end
  end

  defp def_tags(mapping) do
    tags = Enum.map(mapping, &elem(&1, 0))
    quote do
      def tags, do: unquote(tags)
    end
  end
end
