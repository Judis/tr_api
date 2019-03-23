defmodule I18NAPIWeb.TranslationKeyView do
  use I18NAPIWeb, :view
  alias I18NAPIWeb.TranslationKeyView

  def render("200.json", %{}) do
    %{success: true}
  end

  def render("index.json", %{translation_keys: translation_keys}) do
    %{data: render_many(translation_keys, TranslationKeyView, "translation_key.json")}
  end

  def render("show.json", %{translation_key: translation_key}) do
    %{data: render_one(translation_key, TranslationKeyView, "translation_key.json")}
  end

  def render("translation_key.json", %{translation_key: translation_key}) do
    %{
      id: translation_key.id,
      project_id: translation_key.project_id,
      key: translation_key.key,
      context: translation_key.context,
      is_removed: translation_key.is_removed,
      removed_at: translation_key.removed_at
    }
  end
end
