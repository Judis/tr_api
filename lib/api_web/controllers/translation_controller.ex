defmodule I18NAPIWeb.TranslationController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Translations
  alias I18NAPI.Translations.Translation

  action_fallback(I18NAPIWeb.FallbackController)

  def index(conn, _params) do
    render(conn, "index.json",
      translations: Translations.list_translations(conn.params["locale_id"])
    )
  end

  def create(conn, %{"translation" => translation_params}) do
    with true <- Map.has_key?(translation_params, "translation_key_id"),
         %Translation{} <-
           translation =
             Translations.get_translation(
               translation_params["translation_key_id"],
               conn.params["locale_id"]
             ),
         {:ok, %Translation{} = translation} <-
           translation |> Translations.update_translation(translation_params) do
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
    with %Translation{} = translation <- Translations.get_translation!(id) do
      render(conn, "show.json", translation: translation)
    end
  end

  def update(conn, %{"id" => id, "translation" => translation_params}) do
    with %Translation{} = translation <- Translations.get_translation!(id),
         {:ok, %Translation{} = translation} <-
           Translations.update_translation(translation, translation_params) do
      render(conn, "show.json", translation: translation)
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Translation{} = translation <- Translations.get_translation!(id),
         {:ok, %Translation{} = translation} <-
           Translations.safely_delete_translation(translation) do
      render(conn, "200.json")
    end
  end
end
