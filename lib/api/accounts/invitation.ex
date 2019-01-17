defmodule I18NAPI.Accounts.Invitation do
  @moduledoc """
  The user password restoration context.
  """

  import Ecto.Query, warn: false
  alias I18NAPI.Projects
  alias I18NAPI.Projects.UserRoles
  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User
  alias I18NAPI.Mailer
  alias I18NAPI.UserEmail
  alias I18NAPI.Utilities

  @invite_requires [:role, :message]

  def send_invite_email_async({:ok, user}, owner, project, role, message) do
    spawn(I18NAPI.Accounts.Invitation, :send_invite_email, [user, role])
    {:ok, user}
  end

  def send_invite_email_async(result, _, _, _, _), do: result

  def send_invite_email(%User{} = user, owner, project, role, message) do
    with {:ok, _} <-
           UserEmail.create_invitation_email(user, owner, project, role, message)
           |> Mailer.deliver() do
      Accounts.update_field_invited_at(user)
    end
  end

  def check_invite_params(invite_params) do
    Utilities.validate_required(invite_params, @invite_requires)
  end

  def create_invite(invite_params, owner) do
    prepare_user(invite_params, owner)
    |> send_invite_email_async(
      owner,
      Projects.get_project!(invite_params.project_id),
      invite_params.role,
      invite_params.message
    )
  end

  def prepare_user(user_params, owner) do
    with {:ok, %User{} = user} <- Accounts.create_user_with_temp_password(user_params),
         {:ok, %UserRoles{}} <-
           Projects.create_user_roles(%{
             user_id: user.id,
             project_id: user_params.project_id,
             role: user_params.role
           }) do
      Accounts.update_field_restore_token(user, Utilities.random_string(32))
    end
  end

  def prepare_user(_, _) do
    {:error, :forbidden}
  end

  def accept_user_by_token(_, nil, _) do
    {:error, :nil_found}
  end

  def accept_user_by_token(_, _, nil) do
    {:error, :nil_found}
  end

  def accept_user_by_token(restore_token, password, password_confirmation) do
    with {:ok, %User{} = user} <- Accounts.find_user_by_restore_token(restore_token),
         false <- user.is_confirmed do
      Accounts.accept_invitation(user, password, password_confirmation)
    end
  end

  def create_invitation_link(restore_token) do
    I18NAPIWeb.Router.Helpers.invitation_url(I18NAPIWeb.Endpoint, :accept, token: restore_token)
  end
end
