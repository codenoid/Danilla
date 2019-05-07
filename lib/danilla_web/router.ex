defmodule DanillaWeb.Router do
  use DanillaWeb, :router

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

  scope "/", DanillaWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/login", AuthController, :login_view
    post "/login", AuthController, :login
    get "/logout", AuthController, :logout

    get "/secret", SecretController, :secret_view
    get "/secret/ajax", SecretController, :secret_ajax
    post "/secret", SecretController, :secret_new
    get "/secret/delete", SecretController, :secret_delete

    get "/setting", SettingController, :setting_view
    post "/setting", SettingController, :setting_save
    get "/setting/enable", SettingController, :enable
    get "/setting/disable", SettingController, :disable
  end

  scope "/api", DanillaWeb do
    get "/single", ApiController, :one_secret
  end

  # Other scopes may use custom stacks.
  # scope "/api", DanillaWeb do
  #   pipe_through :api
  # end
end
