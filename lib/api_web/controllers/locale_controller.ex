defmodule I18NAPIWeb.LocaleController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Translations
  alias I18NAPI.Translations.Locale

  action_fallback(I18NAPIWeb.FallbackController)

  def index(conn, _params) do
    locales = Translations.list_locales(conn.private[:guardian_default_resource].id)
    render(conn, "index.json", locales: locales)
  end

  def create(conn, %{"locale" => locale_params}) do
    with {:ok, %Locale{} = locale} <-
           Translations.create_locale(
             locale_params,
             conn.params["project_id"]
           ) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", project_locale_path(conn, :show, locale.project_id, locale))
      |> render("show.json", locale: locale)
    end
  end

  def show(conn, %{"id" => id}) do
    locale = Translations.get_locale!(id)

    case locale.is_removed do
      false -> render(conn, "show.json", locale: locale)
      _ -> conn |> put_status(204) |> render("204.json")
    end
  end

  def update(conn, %{"id" => id, "locale" => locale_params}) do
    locale = Translations.get_locale!(id)

    with {:ok, %Locale{} = locale} <- Translations.update_locale(locale, locale_params) do
      case locale.is_removed do
        false -> render(conn, "show.json", locale: locale)
        _ -> conn |> put_status(204) |> render("204.json")
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    locale = Translations.get_locale!(id)

    with {:ok, %Locale{} = locale} <- Translations.safely_delete_locale(locale) do
      case locale.is_removed do
        false -> render(conn, "show.json", locale: locale)
        _ -> conn |> put_status(204) |> render("204.json")
      end
    end
  end

  def keys_and_translations(conn, %{"locale_id" => id}) do
    locale = Translations.get_locale!(id)
    keys_and_translations = Translations.get_keys_and_translations(locale)

    render(conn, "keys_and_translations.json", keys_and_translations: keys_and_translations)
  end
end
