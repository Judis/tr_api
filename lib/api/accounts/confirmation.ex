defmodule I18NAPI.Accounts.Confirmation do
  @moduledoc """
  The user confirmation context.
  """

  import Ecto.Query, warn: false
  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User
  alias I18NAPI.Mailer
  alias I18NAPI.UserEmail

  def send_confirmation_email_async(user) do
    spawn(I18NAPI.Accounts.Confirmation, :send_confirmation_email, [user])
  end

  def send_confirmation_email(%User{} = user) do
    with {:ok, _} <- Mailer.deliver(UserEmail.create_confirmation_email(user)) do
      Accounts.update_field_confirmation_sent_at(user)
    end
  end

  def confirm_user_by_token(nil), do: {:error, :not_found}

  def confirm_user_by_token(confirmation_token) do
    with {:ok, user} <- Accounts.find_user_by_confirmation_token(confirmation_token),
         {:ok, _} <- Accounts.confirm_user(user),
         do: {:ok}
  end

  def create_confirmation_link(confirmation_token) do
    I18NAPIWeb.Router.Helpers.confirmation_url(I18NAPIWeb.Endpoint, :confirm,
      token: confirmation_token
    )
  end
end
