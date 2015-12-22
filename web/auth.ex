defmodule Tev.Auth do
  @moduledoc """
  Provides auth plugs and a controller helper which injects current user into
  arguments to action.

  ## Examples

      defmodule MyController do
        use Tev.Auth, :current_user

        def index(conn, params, current_user) do
        end
      end
  """

  alias Tev.Session
  alias Tev.UnauthorizedError

  @spec authenticate(Plug.Conn.t, Plug.opts) :: Plug.Conn.t
  def authenticate(conn, _opts) do
    case Session.fetch_current_user(conn) do
      {:ok, user} ->
        Plug.Conn.assign(conn, :current_user, user)
      {:error, :stale} ->
        Session.sign_out(conn)
      _ ->
        conn
    end
  end

  @spec authorize(Plug.Conn.t, Plug.opts) :: Plug.Conn.t | no_return
  def authorize(conn, _opts) do
    if Session.signed_in?(conn) do
      conn
    else
      raise UnauthorizedError
    end
  end

  defmacro __using__(:current_user) do
    quote do
      import unquote(__MODULE__)

      plug :authenticate

      def action(conn, _) do
        apply(__MODULE__, action_name(conn),
              [conn, conn.params, conn.assigns[:current_user]])
      end
    end
  end
end
