defmodule I18NAPIWeb.ConfirmationController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User
  alias I18NAPI.Accounts.Confirmation

  action_fallback(I18NAPIWeb.FallbackController)

  def confirm(conn, %{"token" => confirmation_token}) do
    result =  Confirmation.confirm_user_by_token(confirmation_token)
    case result do
      {:ok} -> conn |> put_status(200) |> render("200.json")
      _ -> conn |> put_status(404) |> render("404.json")
    end
  end

  def confirm(_conn, _args) do
    {:error, :bad_request}
  end
end
