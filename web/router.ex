defmodule Tev.Router do
  use Tev.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Tev do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/confidential", PageController, :confidential
    get "/fetch", PageController, :fetch

    get "/login", SessionController, :login
    get "/login/callback", SessionController, :login_callback
    get "/logout", SessionController, :logout
  end

  # Other scopes may use custom stacks.
  # scope "/api", Tev do
  #   pipe_through :api
  # end
end
