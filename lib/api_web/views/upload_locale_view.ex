defmodule I18NAPIWeb.UploadLocaleView do
  use I18NAPIWeb, :view

  def render("200.json", %{}) do
    %{success: true}
  end
end
