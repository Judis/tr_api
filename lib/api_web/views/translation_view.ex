defmodule I18NAPIWeb.TranslationView do
  use I18NAPIWeb, :view
  alias I18NAPIWeb.TranslationView

  def render("index.json", %{translations: translations}) do
    %{data: render_many(translations, TranslationView, "translation.json")}
  end

  def render("show.json", %{translation: translation}) do
    %{data: render_one(translation, TranslationView, "translation.json")}
  end

  def render("translation.json", %{translation: translation}) do
    %{
      id: translation.id,
      locale_id: translation.locale_id,
      translation_key_id: translation.translation_key_id,
      value: translation.value,
      is_removed: translation.is_removed,
      removed_at: translation.removed_at
    }
  end
end
