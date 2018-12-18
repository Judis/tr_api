defmodule I18NAPIWeb.ConfirmationView do
  use I18NAPIWeb, :view
  alias I18NAPIWeb.ConfirmationView

  def render("200.json", _) do
    %{ok: %{detail: "User confirmed"}}
  end


  def render("404.json", _assigns) do
    %{errors: %{detail: "Not Found"}}
  end
end
