defmodule I18NAPIWeb.UserLocaleView do
  use I18NAPIWeb, :view
  alias I18NAPIWeb.UserLocaleView

  def render("200.json", %{}) do
    %{success: true}
  end

  def render("index.json", %{user_locale: user_locale}) do
    %{data: render_many(user_locale, UserLocaleView, "user_locale.json")}
  end

  def render("show.json", %{user_locale: user_locale}) do
    %{data: render_one(user_locale, UserLocaleView, "user_locale.json")}
  end

  def render("user_locale.json", %{user_locale: user_locale}) do
    %{id: user_locale.id, role: user_locale.role}
  end
end
