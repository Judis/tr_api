defmodule I18NAPI.Accounts.Confirmation do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias I18NAPI.Repo
  alias I18NAPI.Mailer
  alias I18NAPI.Utilites
  alias I18NAPI.UserEmail
  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User


  def send_confirmation_email_async({:error, _} = result) do
    result
  end

  def send_confirmation_email_async({:ok, %User{} = user} = result) do
    spawn(I18NAPI.Accounts.Confirmation, :send_confirmation_email, [result])
    result
  end

  def send_confirmation_email({:ok, %User{} = user}) do
    confirmation_token = Utilites.random_string(32)

    email = UserEmail.deliver_confirmation_email(user |> Map.put(:confirmation_token, confirmation_token))

    user |> Accounts.update_user(%{
      confirmation_token: confirmation_token,
      confirmation_send_at: NaiveDateTime.utc_now
    })
  end

  def confirm_user_by_token(confirmation_token) do
    with {:ok, user} <- Accounts.find_user_by_confirmation_token(confirmation_token),
         {:ok, user} <- Accounts.confirm_user(user), do: {:ok}
  end
end