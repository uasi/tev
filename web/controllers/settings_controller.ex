defmodule Tev.SettingsController do
  use Tev.Web, :controller
  use Tev.Auth, authorize: true
  use Tev.Auth, :current_user

  alias Tev.SettingsView

  def account(conn, _params, user) do
    render conn, "account.html", view: SettingsView.new(user)
  end
end
