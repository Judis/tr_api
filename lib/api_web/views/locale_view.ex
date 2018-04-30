defmodule I18NAPIWeb.LocaleView do
  use I18NAPIWeb, :view
  alias I18NAPIWeb.LocaleView

  def render("index.json", %{locales: locales}) do
    %{data: render_many(locales, LocaleView, "locale.json")}
  end

  def render("show.json", %{locale: locale}) do
    %{data: render_one(locale, LocaleView, "locale.json")}
  end

  def render("locale.json", %{locale: locale}) do
    %{
      id: locale.id,
      project_id: locale.project_id,
      locale: locale.locale,
      is_default: locale.is_default,
      count_of_keys: locale.count_of_keys,
      count_of_words: locale.count_of_words,
      count_of_translated_keys: locale.count_of_translated_keys,
      is_removed: locale.is_removed,
      removed_at: locale.removed_at
    }
  end
end
