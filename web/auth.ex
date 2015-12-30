defmodule Tev.Auth do
  @moduledoc """
  Provides controller helpers for authentication/authorization.
  """

  alias Tev.Session
  alias Tev.UnauthorizedError

  @doc false
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

  @doc false
  @spec authorize(Plug.Conn.t, Plug.opts) :: Plug.Conn.t | no_return
  def authorize(conn, _opts) do
    if Session.signed_in?(conn) do
      conn
    else
      raise UnauthorizedError
    end
  end

  @doc """
  `use Tev.Auth, :current_user` injects current user into arguments to action
  function.

  If current user has been set by `Session.put_current_user/1`, fetch it and
  inject as the third argument to action function. Otherwise set nil to the
  third argument.

  ## Examples

      defmodule MyController do
        use Tev.Auth, :current_user

        def index(conn, params, current_user) do
        end
      end

  `use Tev.Auth, authorize: default_boolean` controls authorization.

  An action which function is preceded by `@authorize true` requires
  `conn.assigns[:current_user]` to be set to non-nil. If this requirement isn't
  met, the action will raise `Tev.UnauthorizedError`.
  Precede an action function by `@authorize false` to disable this behavior.

  If neither attribute is defined for an action function, it will be assumed
  that the function is preceded by `@authorize default_boolean` where
  `default_boolean` is the value given as
  `use Auth.Tev, authorize: default_boolean`.

  ## Examples

      defmodule MyController1 do
        use Tev.Auth, authorize: false

        def unclassified(conn, _params) do
          ...
        end

        @authorize true
        def confidential(conn, _params) do
          # Raises Tev.UnauthorizedError unless conn.assigns[:current_user] is set.
        end
      end

      defmodule MyController2 do
        use Tev.Auth, authorize: true

        @authorize false
        def unclassified(conn, _params) do
          ...
        end

        def confidential(conn, _params) do
          # Raises Tev.UnauthorizedError unless conn.assigns[:current_user] is set.
        end
      end
  """
  @spec __using__(:current_user) :: term
  @spec __using__([authorize: boolean]) :: term
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
  defmacro __using__([authorize: default]) do
    quote do
      import unquote(__MODULE__)

      Module.register_attribute(__MODULE__, :authorize, accumulate: true)

      @authorize unquote(default)
      @on_definition {unquote(__MODULE__), :put_authorize_plug}
    end
  end

  @doc false
  def put_authorize_plug(env, _kind, name, _args, _guards, _body) do
    attrs = Module.get_attribute(env.module, :authorize)
    default = List.last(attrs)
    authorize = List.first(attrs)
    if authorize do
      plug = {:authorize, [], quote(do: var!(action) == unquote(name))}
      Module.put_attribute(env.module, :plugs, plug)
    end
    if authorize != default do
      Module.put_attribute(env.module, :authorize, default)
    end
  end
end
