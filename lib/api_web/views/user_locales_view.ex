defmodule I18NAPIWeb.UserLocaleView do
  use I18NAPIWeb, :view
  alias I18NAPIWeb.UserLocaleView

  def render("index.json", %{user_locales: user_locales}) do
    %{data: render_many(user_locales, UserLocaleView, "user_locale.json")}
  end

  def render("show.json", %{user_locales: user_locales}) do
    %{data: render_one(user_locales, UserLocaleView, "user_locale.json")}
  end

  def render("user_locale.json", %{user_locales: user_locales}) do
    %{id: user_locales.id, role: user_locales.role}
  end
end
