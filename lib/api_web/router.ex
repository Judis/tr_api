defmodule I18NAPIWeb.Router do
  use I18NAPIWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :authenticated do
    plug(:set_user)
  end

  scope "/", I18NAPIWeb do
    pipe_through(:api)
    get("/", EchoController, :index)
  end

  scope "/api", I18NAPIWeb do
    pipe_through(:api)
    resources("/users", UserController)

    pipe_through(:authenticated)
    resources("/projects", ProjectController)
    resources("/locales", LocaleController)
    resources("/translation_keys", TranslationKeyController)
    resources("/user_locales", UserLocalesController)
    resources("/user_roles", UserRolesController)
  end

  defp set_user(conn, _) do
    user_id =
      conn
      |> get_req_header("authorization")
      |> List.first()

    assign(conn, :user, I18NAPI.Accounts.get_user!(user_id))
  end
end
