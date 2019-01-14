defmodule I18NAPI.UserEmail do
  use Phoenix.Swoosh, view: I18NAPIWeb.EmailView, layout: {I18NAPIWeb.LayoutView, :email}

  alias I18NAPI.Accounts.{Confirmation, Invitation, Restoration}

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

  def create_invitation_email(user, owner, project, role, message) do
    new()
    |> to({user.name, user.email})
    |> from({Application.fetch_env!(:api, :sender), Application.fetch_env!(:api, :sender_email)})
    |> subject("i18n invitation email")
    |> render_body("invitation_email.html", %{
      username: user.name,
      invite_token: user.restore_token,
      invite_link: Invitation.create_invitation_link(user.restore_token),
      owner: owner.name,
      owner_email: owner.email,
      project: project.name,
      message: message,
      role: role
    })
  end
end
