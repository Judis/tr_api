defmodule I18NAPI.UserEmail do
  use Phoenix.Swoosh, view: I18NAPIWeb.EmailView, layout: {I18NAPIWeb.LayoutView, :email}

  alias I18NAPI.Accounts.{Confirmation, Restoration}
  alias I18NAPI.Projects.Invitation

  def create_confirmation_email(user) do
    new()
    |> to({user.name, user.email})
    |> from({Application.fetch_env!(:api, :sender), Application.fetch_env!(:api, :sender_email)})
    |> subject("i18n confirmation email")
    |> render_body("confirmation_email.html", %{
      username: user.name,
      confirmation_token: user.confirmation_token,
      confirmation_link: Confirmation.create_confirmation_link(user.confirmation_token)
    })
  end

  def create_restoration_email(user) do
    new()
    |> to({user.name, user.email})
    |> from({Application.fetch_env!(:api, :sender), Application.fetch_env!(:api, :sender_email)})
    |> subject("i18n restoration email")
    |> render_body("restoration_email.html", %{
      username: user.name,
      restore_token: user.restore_token,
      restoration_link: Restoration.create_restoration_link(user.restore_token)
    })
  end

  def create_invite_email_for_confirmed_user(%{
        invite: invite,
        recipient: recipient,
        inviter: inviter,
        project: project,
        invite_link: invite_link
      }) do
    new()
    |> to({recipient.name, recipient.email})
    |> from({Application.fetch_env!(:api, :sender), Application.fetch_env!(:api, :sender_email)})
    |> subject("i18n invitation email")
    |> render_body("invitation_confirmed_user_email.html", %{
      username: recipient.name,
      token: invite.token,
      invite_link: invite_link,
      inviter: inviter.name,
      project: project.name,
      message: invite.message,
      role: invite.role
    })
  end

  def create_invite_email_for_not_unconfirmed_user(%{
        invite: invite,
        recipient: recipient,
        inviter: inviter,
        project: project,
        invite_link: invite_link
      }) do
    new()
    |> to({recipient.name, recipient.email})
    |> from({Application.fetch_env!(:api, :sender), Application.fetch_env!(:api, :sender_email)})
    |> subject("i18n invitation email")
    |> render_body("invitation_not_confirmed_user_email.html", %{
      username: recipient.name,
      token: invite.token,
      invite_link: invite_link,
      inviter: inviter.name,
      project: project.name,
      message: invite.message,
      role: invite.role
    })
  end
end
