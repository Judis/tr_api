defmodule I18NAPIWeb.LocaleController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Translations
  alias I18NAPI.Translations.Locale

  action_fallback(I18NAPIWeb.FallbackController)

  def index(conn, _params) do
    locales = Translations.list_locales()
    render(conn, "index.json", locales: locales)
  end

  def create(conn, %{"locale" => locale_params}) do
    with {:ok, %Locale{} = locale} <-
           Translations.create_locale(
             locale_params
             |> set_project_id(conn)
           ) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", project_locale_path(conn, :show, locale.project_id, locale))
      |> render("show.json", locale: locale)
    end
  end

  def show(conn, %{"id" => id}) do
    locale = Translations.get_locale!(id)
    render(conn, "show.json", locale: locale)
  end

  def update(conn, %{"id" => id, "locale" => locale_params}) do
    locale = Translations.get_locale!(id)

    with {:ok, %Locale{} = locale} <- Translations.update_locale(locale, locale_params) do
      render(conn, "show.json", locale: locale)
    end
  end

  def delete(conn, %{"id" => id}) do
    locale = Translations.get_locale!(id)

    with {:ok, %Locale{}} <- Translations.delete_locale(locale) do
      send_resp(conn, :no_content, "")
    end
  end

  defp set_project_id(locale, conn) do
    Map.put(locale, "project_id", conn.params["project_id"])
  end
end
