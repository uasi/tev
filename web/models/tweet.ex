defmodule Tev.Tweet do
  use Tev.Web, :model

  @primary_key {:id, :integer, autogenerate: false}

  schema "tweets" do
    field :object, :map
  end

  @type t :: %__MODULE__{}

  @required_fields ~w(
    object
  )
  @optional_fields ~w(
  )

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
