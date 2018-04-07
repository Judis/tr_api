defmodule I18NAPIWeb.Router do
  use I18NAPIWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", I18NAPIWeb do
    pipe_through :api
    get "/", EchoController, :index
  end

  scope "/api", I18NAPIWeb do
    pipe_through :api
    resources "/users", UserController
    resources "/projects", ProjectController
    resources "/locales", LocaleController
    resources "/translation_keys", TranslationKeyController
    resources "/user_locales", UserLocalesController
    resources "/user_roles", UserRolesController
  end
end
