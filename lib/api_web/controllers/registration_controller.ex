defmodule I18NAPIWeb.RegistrationController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User

  action_fallback(I18NAPIWeb.FallbackController)

  def sign_up(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params),
         {:ok, jwt, _} <- I18NAPI.Guardian.encode_and_sign(user) do
      render(conn, "sign_up.json", user: user, jwt: jwt)
    end
  end

  def sign_up(_conn, _args), do: {:error, :bad_request}
end
