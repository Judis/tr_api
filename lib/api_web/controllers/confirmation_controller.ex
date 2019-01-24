defmodule I18NAPIWeb.ConfirmationController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Accounts.Confirmation

  action_fallback(I18NAPIWeb.FallbackController)

  def confirm(conn, %{"token" => confirmation_token}) do
    with {:ok, _} <- Confirmation.confirm_user_by_token(confirmation_token) do
      render(conn, "200.json")
    else
      {:error, :unauthorized} -> {:error, :not_found}
    end
  end

  def confirm(_conn, _args), do: {:error, :bad_request}
end
