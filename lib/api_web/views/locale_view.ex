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
      total_count_of_translation_keys: locale.total_count_of_translation_keys,
      count_of_not_verified_keys: locale.count_of_not_verified_keys,
      count_of_verified_keys: locale.count_of_verified_keys,
      count_of_translated_keys: locale.count_of_translated_keys,
      count_of_untranslated_keys: locale.count_of_untranslated_keys,
      is_removed: locale.is_removed,
      removed_at: locale.removed_at
    }
  end

  def render("key_with_translations.json", %{locale: locale}) do
    %{
      translation_key_id: locale.translation_key_id,
      key: locale.key,
      context: locale.context,
      status: locale.status,
      default_value: locale.default_value,
      current_value: locale.current_value
    }
  end

  def render("keys_and_translations.json", %{keys_and_translations: keys_and_translations}) do
    %{data: render_many(keys_and_translations, LocaleView, "key_with_translations.json")}
  end

  def render("204.json", _) do
    %{errors: %{detail: "No Content"}}
  end
end
