defmodule I18NAPIWeb.Router do
  use I18NAPIWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(I18NAPI.Guardian.AuthPipeline.JSON)
  end

  pipeline :authenticated do
    plug(I18NAPI.Guardian.AuthPipeline.Authenticate)
  end

  scope "/", I18NAPIWeb do
    pipe_through(:api)
    get("/", EchoController, :index)
  end

  scope "/api", I18NAPIWeb do
    pipe_through(:api)
    post("/sign_in", SessionController, :sign_in)
    post("/sign_up", RegistrationController, :sign_up)
    post("/confirm", ConfirmationController, :confirm)
    pipe_through(:authenticated)
    resources("/users", UserController)

    resources("/projects", ProjectController) do
      resources("/translation_keys", TranslationKeyController)

      resources("/locales", LocaleController) do
        get("/keys_and_translations", LocaleController, :keys_and_translations)
        resources("/translations", TranslationController)
      end
    end

    resources("/user_locales", UserLocalesController)
    resources("/user_roles", UserRolesController)
  end
end
