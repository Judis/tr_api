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
    post("/request_reset_password", RestorationController, :request)
    post("/reset_password", RestorationController, :reset)
    post("/accept_user_invite", InvitationController, :accept_user)
    pipe_through(:authenticated)
    resources("/users", UserController)

    resources("/projects", ProjectController) do
      post("/accept_invite", InvitationController, :accept_project)
      post("/create_invite", InvitationController, :invite)
      delete("/reject_invite", InvitationController, :reject)
      resources("/translation_keys", TranslationKeyController)
      resources("/user_roles", UserRoleController)

      resources("/locales", LocaleController) do
        resources("/user_locales", UserLocaleController)
        get("/keys_and_translations", LocaleController, :keys_and_translations)
        resources("/translations", TranslationController)
      end
    end
  end
end
