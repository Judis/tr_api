defmodule I18NAPIWeb.UserLocaleController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Projects
  alias I18NAPI.Translations
  alias I18NAPI.Translations.UserLocale

  action_fallback(I18NAPIWeb.FallbackController)

  def index(conn, _params) do
    render(conn, "index.json", user_locale: Translations.list_user_locales_not_removed())
  end

  def create(conn, %{"user_locale" => user_locale_params}) do
    with {:ok, %UserLocale{} = user_locale} <- Translations.create_user_locale(user_locale_params) do
      conn
      |> put_status(:created)
      |> render("show.json", user_locale: user_locale)
    end
  end

  def show(conn, %{"id" => id}) do
    with %UserLocale{} = user_locale <- Translations.get_user_locale_not_removed(id) do
      render(conn, "show.json", user_locale: user_locale)
    end
  end

  def update(conn, %{"id" => id, "user_locale" => user_locale_params}) do
    with {:ok, %UserLocale{} = user_locale} <-
           Translations.get_user_locale_not_removed(id)
           |> Translations.update_user_locale(user_locale_params) do
      render(conn, "show.json", user_locale: user_locale)
    end
  end

  def delete(conn, %{"id" => id}) do
    with %UserLocale{} = user_locale <- Translations.get_user_locale(id),
         {:ok, _} <- Translations.safely_delete_user_locale(user_locale) do
      render(conn, "200.json")
    end
  end
end
