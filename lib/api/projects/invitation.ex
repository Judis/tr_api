defmodule I18NAPI.Projects.Invitation do
  @moduledoc """
  The user password restoration context.
  """

  import Ecto.Query, warn: false
  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User
  alias I18NAPI.Mailer
  alias I18NAPI.Projects
  alias I18NAPI.Projects.{Invite, Project, UserRoles}
  alias I18NAPI.UserEmail
  alias I18NAPI.Utilities

  @invite_requires [:role, :message]

  def send_invite_email_async({:ok, invite}, recipient, inviter, project, :exist) do
    spawn(
      I18NAPI.Projects.Invitation,
      :create_link_and_send_email_for_confirmed_user,
      [{:ok, invite}, recipient, inviter, project]
    )

    {:ok, invite}
  end

  def send_invite_email_async({:ok, invite}, recipient, inviter, project, :not_exist) do
    spawn(
      I18NAPI.Projects.Invitation,
      :create_link_and_send_email_for_not_confirmed_user,
      [{:ok, invite}, recipient, inviter, project]
    )

    {:ok, invite}
  end

  def send_invite_email_async(result, _, _, _, _), do: result

  def create_link_and_send_email_for_confirmed_user({:ok, invite}, recipient, inviter, project) do
    with {:ok, invite_link} <- create_invitation_project_link(project.id, invite.token),
         {:ok, _} <-
           UserEmail.create_invite_email_for_confirmed_user(%{
             invite: invite,
             recipient: recipient,
             inviter: inviter,
             project: project,
             invite_link: invite_link
           })
           |> Mailer.deliver() do
      Projects.update_field_invited_at(invite)
    end
  end

  def create_link_and_send_email_for_confirmed_user(result, _, _, _), do: result

  def create_link_and_send_email_for_not_confirmed_user(
        {:ok, invite},
        recipient,
        inviter,
        project
      ) do
    with {:ok, invite_link} <- create_invitation_user_link(invite.token),
         {:ok, _} <-
           UserEmail.create_invite_email_for_not_unconfirmed_user(%{
             invite: invite,
             recipient: recipient,
             inviter: inviter,
             project: project,
             invite_link: invite_link
           })
           |> Mailer.deliver() do
      Projects.update_field_invited_at(invite)
    end
  end

  def create_link_and_send_email_for_not_confirmed_user(result, _, _, _), do: result

  def check_invite_params(invite_params) do
    Utilities.validate_required(invite_params, @invite_requires)
  end

  def start_invitation_process(invite_params, inviter) do
    with %Project{} = project <- Projects.get_project!(invite_params.project_id) do
      with {:ok, recipient} <- Accounts.find_user_by_email(invite_params.email) do
        invite_params
        |> Map.put(:recipient_id, recipient.id)
        |> Projects.create_invite()
        |> send_invite_email_async(recipient, inviter, project, :exist)
      else
        {:error, :not_founded} ->
          with {:ok, %User{} = recipient} <- prepare_user(invite_params) do
            invite_params
            |> Map.put(:recipient_id, recipient.id)
            |> Projects.create_invite()
            |> send_invite_email_async(recipient, inviter, project, :not_exist)
          end
      end
    else
      _ -> {:error, :not_founded}
    end
  end

  def prepare_user(user_params) do
    with {:ok, %User{} = user} <- Accounts.create_user_with_temp_password(user_params) do
      Accounts.update_field_restore_token(user, Utilities.random_string(32))
    end
  end

  def accept_user_by_token(token, password, password_confirmation) do
    with {:ok, %Invite{} = invite} <- Projects.find_invite_by_token(token),
         %User{} = user <- Accounts.get_user(invite.recipient_id),
         {:ok, %User{} = user} <- Accounts.confirm_user(user),
         {:ok, %User{}} <- Accounts.accept_invitation(user, password, password_confirmation),
         {:ok, %UserRoles{}} <-
           Projects.create_user_roles(%{
             project_id: invite.project_id,
             user_id: invite.recipient_id,
             role: invite.role
           }),
         {:ok, %Invite{}} <- Projects.accept_invite(invite) do
      {:ok, user}
    end
  end

  def accept_project_by_token(token) do
    with {:ok, %Invite{} = invite} <- Projects.find_invite_by_token(token),
         {:ok, %UserRoles{}} <-
           Projects.create_user_roles(%{
             project_id: invite.project_id,
             user_id: invite.recipient_id,
             role: invite.role
           }) do
      Projects.accept_invite(invite)
    end
  end

  def create_invitation_user_link(token) do
    I18NAPIWeb.Router.Helpers.invitation_url(I18NAPIWeb.Endpoint, :accept_user, token: token)
  end

  def create_invitation_project_link(project_id, token) do
    I18NAPIWeb.Router.Helpers.project_invitation_url(
      I18NAPIWeb.Endpoint,
      :accept_project,
      project_id,
      token: token
    )
  end
end
