defmodule Tev.SettingsView do
  defstruct [:user]
  @type t :: %__MODULE__{}

  use Tev.Web, :view

  alias Tev.User

  @spec new(User.t) :: t
  def new(user) do
    %__MODULE__{user: user}
  end
end
