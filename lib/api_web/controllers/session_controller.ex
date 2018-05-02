defmodule I18NAPIWeb.SessionController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User

  action_fallback(I18NAPIWeb.FallbackController)

  def sign_in(conn, %{"session" => %{"email" => email, "password" => password}}) do
    with {:ok, %User{} = user} <- Accounts.find_and_confirm_user(email, password) do
      {:ok, jwt, _full_claims} = I18NAPI.Guardian.encode_and_sign(user)

      conn
      |> render("sign_in.json", user: user, jwt: jwt)
    end
  end

  def sign_in(_conn, _args) do
    {:error, :bad_request}
  end
end
