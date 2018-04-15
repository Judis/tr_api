defmodule I18NAPIWeb.UserLocalesView do
  use I18NAPIWeb, :view
  alias I18NAPIWeb.UserLocalesView

  def render("index.json", %{user_locales: user_locales}) do
    %{data: render_many(user_locales, UserLocalesView, "user_locales.json")}
  end

  def render("show.json", %{user_locales: user_locales}) do
    %{data: render_one(user_locales, UserLocalesView, "user_locales.json")}
  end

  def render("user_locales.json", %{user_locales: user_locales}) do
    %{id: user_locales.id, role: user_locales.role}
  end
end
