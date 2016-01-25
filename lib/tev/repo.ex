defmodule Tev.Repo do
  use Ecto.Repo, otp_app: :tev
  use Scrivener, page_size: 100

  @spec reload(Ecto.Schema.t) :: Ecto.Schema.t
  def reload(model) do
    schema = model.__struct__
    case schema.__schema__(:primary_key) do
      [pkey] ->
        get(schema, Map.get(model, pkey))
      pkeys ->
        raise ArgumentError,
          "#{__MODULE__}.reload/1 requires the schema #{inspect schema} " <>
          "to have exactly one primary key, got: #{inspect pkeys}"
    end
  end
end
