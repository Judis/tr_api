defmodule I18NAPIWeb.EchoView do
  use I18NAPIWeb, :view
  alias I18NAPIWeb.EchoView

  def render("index.json", %{}) do
    %{success: true}
  end
end
