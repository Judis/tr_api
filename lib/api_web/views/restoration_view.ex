defmodule I18NAPIWeb.RestorationView do
  use I18NAPIWeb, :view

  def render("200.json", _) do
    %{ok: %{detail: "User confirmed"}}
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
end
