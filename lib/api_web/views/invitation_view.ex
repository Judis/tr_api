defmodule I18NAPIWeb.InvitationView do
  use I18NAPIWeb, :view
  alias I18NAPIWeb.InvitationView

  def render("show.json", %{invite: invite}) do
    %{data: render_one(invite, InvitationView, "invite.json")}
  end

  def render("200.json", _) do
    %{ok: %{detail: "User accepted"}}
  end

  def render("422.json", %{detail: :password}) do
    %{
      error: %{
        detail: "Password must have 8-50 symbols"
      }
    }
  end

  def render("422.json", %{detail: :password_confirmation}) do
    %{error: %{detail: "Does not match confirmation"}}
  end

  def render("422.json", _) do
    %{error: %{detail: "Unprocessable Entity"}}
  end

  def render("invite.json", %{invitation: invite}) do
    %{
      id: invite.id,
      inviter_id: invite.inviter_id,
      recipient_id: invite.recipient_id,
      project_id: invite.project_id,
      role: invite.role,
      message: invite.message,
      invited_at: invite.invited_at
    }
  end
end
