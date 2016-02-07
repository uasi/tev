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
    plug :fetch_session
  end

  scope "/", Tev do
    pipe_through :browser

    get "/", PageController, :index
    get "/confidential", PageController, :confidential
    get "/fetch", PageController, :fetch
    get "/likes", PageController, :likes

    get "/login", SessionController, :login
    get "/login/callback", SessionController, :login_callback
    get "/logout", SessionController, :logout

    get "/settings/account", SettingsController, :account
  end

  scope "/api", Tev do
    pipe_through :api

    get "/rendered_tweets", ApiController, :rendered_tweets
  end
end
