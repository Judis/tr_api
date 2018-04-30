defmodule I18NAPIWeb.TranslationController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Translations
  alias I18NAPI.Translations.Translation

  action_fallback(I18NAPIWeb.FallbackController)

  def index(conn, _params) do
    translations = Translations.list_translations(conn.params["locale_id"])
    render(conn, "index.json", translations: translations)
  end

  def create(conn, %{"translation" => translation_params}) do
    with {:ok, %Translation{} = translation} <-
           Translations.create_translation(
             translation_params,
             conn.params["locale_id"]
           ) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        project_locale_translation_path(
          conn,
          :show,
          conn.params["project_id"],
          translation.locale_id,
          translation
        )
      )
      |> render("show.json", translation: translation)
    end
  end

  def show(conn, %{"id" => id}) do
    translation = Translations.get_translation!(id)
    render(conn, "show.json", translation: translation)
  end

  def update(conn, %{"id" => id, "translation" => translation_params}) do
    translation = Translations.get_translation!(id)

    with {:ok, %Translation{} = translation} <-
           Translations.update_translation(translation, translation_params) do
      render(conn, "show.json", translation: translation)
    end
  end

  def delete(conn, %{"id" => id}) do
    translation = Translations.get_translation!(id)

    with {:ok, %Translation{} = translation} <-
           Translations.safely_delete_translation(translation) do
      render(conn, "show.json", translation: translation)
    end
  end
end
