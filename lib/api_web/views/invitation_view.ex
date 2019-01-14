defmodule I18NAPIWeb.InvitationView do
  use I18NAPIWeb, :view
  alias I18NAPIWeb.InvitationView

  def render("show.json", %{user: user}) do
    %{data: render_one(user, InvitationView, "user.json")}
  end

  def render("200.json", _) do
    %{ok: %{detail: "User accepted"}}
  end

  def render("422.json", %{detail: :password}) do
    %{
      error: %{
        detail:
          "Password must have 8-255 symbols, include at least one lowercase letter, one uppercase letter, and one digit"
      }
    }
  end

  def render("422.json", %{detail: :password_confirmation}) do
    %{error: %{detail: "Does not match confirmation"}}
  end

  def render("422.json", _) do
    %{error: %{detail: "Unprocessable Entity"}}
  end

  def render("user.json", %{invitation: user}) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      is_confirmed: user.is_confirmed,
      source: user.source,
      invited_at: user.invited_at
    }
  end
end
