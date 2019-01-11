defmodule I18NAPIWeb.TranslationKeyController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Translations
  alias I18NAPI.Translations.TranslationKey

  action_fallback(I18NAPIWeb.FallbackController)

  def index(conn, _params) do
    translation_keys = Translations.list_translation_keys(conn.params["project_id"])
    render(conn, "index.json", translation_keys: translation_keys)
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
    translation_key = Translations.get_translation_key!(id)

    case translation_key.is_removed do
      false -> render(conn, "show.json", translation_key: translation_key)
      _ -> conn |> put_status(204) |> render("204.json")
    end
  end

  def update(conn, %{"id" => id, "translation_key" => translation_key_params}) do
    translation_key = Translations.get_translation_key!(id)

    with {:ok, %TranslationKey{} = translation_key} <-
           Translations.update_translation_key(translation_key, translation_key_params) do
      case translation_key.is_removed do
        false -> render(conn, "show.json", translation_key: translation_key)
        _ -> conn |> put_status(204) |> render("204.json")
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    translation_key = Translations.get_translation_key!(id)

    with {:ok, %TranslationKey{} = translation_key} <-
           Translations.safely_delete_translation_key(translation_key) do
      case translation_key.is_removed do
        false -> render(conn, "show.json", translation_key: translation_key)
        _ -> conn |> put_status(204) |> render("204.json")
      end
    end
  end
end
