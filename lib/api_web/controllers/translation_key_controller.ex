defmodule I18NAPIWeb.TranslationKeyController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Translations
  alias I18NAPI.Translations.TranslationKey

  action_fallback(I18NAPIWeb.FallbackController)

  def index(conn, _params) do
    render(conn, "index.json",
      translation_keys: Translations.list_translation_keys_not_removed(conn.params["project_id"])
    )
  end

  def create(conn, %{"translation_key" => translation_key_params}) do
    with {:ok, %TranslationKey{} = translation_key} <-
           Translations.create_translation_key(
             translation_key_params,
             conn.params["project_id"]
           ) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        project_translation_key_path(
          conn,
          :show,
          translation_key.project_id,
          translation_key
        )
      )
      |> render("show.json", translation_key: translation_key)
    end
  end

  def show(conn, %{"id" => id}) do
    with %TranslationKey{} = translation_key <- Translations.get_translation_key_not_removed(id) do
      render(conn, "show.json", translation_key: translation_key)
    end
  end

  def update(conn, %{"id" => id, "translation_key" => translation_key_params}) do
    with %TranslationKey{} = translation_key <- Translations.get_translation_key!(id),
         {:ok, %TranslationKey{} = translation_key} <-
           Translations.update_translation_key(translation_key, translation_key_params) do
      render(conn, "show.json", translation_key: translation_key)
    end
  end

  def delete(conn, %{"id" => id}) do
    with %TranslationKey{} = translation_key <- Translations.get_translation_key!(id),
         {:ok, %TranslationKey{} = translation_key} <-
           Translations.safely_delete_translation_key(translation_key) do
      render(conn, "200.json")
    end
  end
end
