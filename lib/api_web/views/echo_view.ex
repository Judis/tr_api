defmodule I18NAPIWeb.EchoView do
  use I18NAPIWeb, :view

  def render("index.json", %{}) do
    %{success: true}
  end
end
