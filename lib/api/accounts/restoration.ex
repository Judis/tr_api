defmodule I18NAPI.Accounts.Restoration do
  @moduledoc """
  The user password restoration context.
  """

  import Ecto.Query, warn: false
  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User
  alias I18NAPI.Mailer
  alias I18NAPI.UserEmail
  alias I18NAPI.Utilites

  def send_password_restore_email_async(user) do
    spawn(I18NAPI.Accounts.Confirmation, :send_password_restore_email, [user])
  end

  def send_password_restore_email(%User{} = user) do
    with {:ok, updated_user} =
           Accounts.update_field_restore_token(user, Utilites.random_string(32)),
         {:ok, _} <- Mailer.deliver(UserEmail.create_restoration_email(updated_user)) do
      Accounts.update_field_password_restore_requested_at(updated_user)
    end
  end

  def confirm_user_by_restoration_token(nil), do: {:error, :not_found}

  def create_restoration_link(restore_token) do
    I18NAPIWeb.Router.Helpers.restoration_url(I18NAPIWeb.Endpoint, :request, token: restore_token)
  end

  def start_password_restoration(email) do
    with {:ok, %User{} = user} <- Accounts.find_user_by_email(email) do
      send_password_restore_email_async(user)
    end
  end

  def restore_user_by_token(nil, _, _) do
    {:error, :nil_found}
  end

  def restore_user_by_token(_, nil, _) do
    {:error, :nil_found}
  end

  def restore_user_by_token(_, _, nil) do
    {:error, :nil_found}
  end

  def restore_user_by_token(restore_token, password, password_confirmation) do
    with {:ok, %User{} = user} <- Accounts.find_user_by_restore_token(restore_token) do
      Accounts.accept_restoration(user, password, password_confirmation)
    end
  end
end
