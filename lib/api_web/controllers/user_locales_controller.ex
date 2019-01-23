defmodule I18NAPIWeb.UserLocaleController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Projects
  alias I18NAPI.Translations
  alias I18NAPI.Translations.UserLocale

  action_fallback(I18NAPIWeb.FallbackController)

  def index(conn, _params) do
    user_locales = Translations.list_user_locales()
    render(conn, "index.json", user_locales: user_locales)
  end

  def create(conn, %{"user_locale" => user_locale_params}) do
    with {:ok, %UserLocale{} = user_locale} <- Translations.create_user_locales(user_locale_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_locale_path(conn, :show, user_locale))
      |> render("show.json", user_locales: user_locale)
    end
  end

  def show(conn, %{"id" => id}) do
    user_locale = Translations.get_user_locale!(id)
    render(conn, "show.json", user_locale: user_locale)
  end

  def update(conn, %{"id" => id, "user_locale" => user_locale_params}) do
    user_locale = Translations.get_user_locale!(id)

    with {:ok, %UserLocale{} = user_locale} <-
           Translations.update_user_locales(user_locale, user_locale_params) do
      render(conn, "show.json", user_locale: user_locale)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_locale = Translations.get_user_locale!(id)

    with {:ok, %UserLocale{}} <- Translations.delete_user_locales(user_locale) do
      send_resp(conn, :no_content, "")
    end
  end
end
