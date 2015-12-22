defmodule Tev.Session do
  import Plug.Conn

  alias Tev.Repo
  alias Tev.User

  @spec sign_in(Plug.Conn.t, User.t) :: Plug.Conn.t
  def sign_in(conn, user) do
    put_session(conn, :user_id, user.id)
  end

  @spec sign_out(Plug.Conn.t) :: Plug.Conn.t
  def sign_out(conn) do
    clear_session(conn)
  end

  @spec signed_in?(Plug.Conn.t) :: boolean
  def signed_in?(conn) do
    {res, _} = fetch_current_user(conn)
    res == :ok
  end

  @spec fetch_current_user(Plug.Conn.t) :: {:ok, User.t} | {:error, :not_found | :stale}
  def fetch_current_user(conn) do
    case get_session(conn, :user_id) do
      nil ->
        {:error, :not_found}
      user_id ->
        case Repo.get(User, user_id) do
          nil ->
            {:error, :stale}
          user ->
            {:ok, user}
        end
    end
  end
end
