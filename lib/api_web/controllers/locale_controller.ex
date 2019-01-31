defmodule I18NAPIWeb.LocaleController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Composers
  alias I18NAPI.Parsers
  alias I18NAPI.Translations
  alias I18NAPI.Translations.{Export, Import, Locale}

  action_fallback(I18NAPIWeb.FallbackController)

  def index(conn, _params) do
    render(conn, "index.json",
      locales: Translations.list_locales(conn.private[:guardian_default_resource].id)
    )
  end

  def create(conn, %{"locale" => locale_params}) do
    with {:ok, %Locale{} = locale} <-
           Translations.create_locale(
             locale_params,
             conn.params["project_id"]
           ) do
      conn
      |> put_status(:created)
      |> render("show.json", locale: locale)
    end
  end

  def show(conn, %{"id" => id}) do
    with %Locale{} = locale <- Translations.get_locale_not_removed(id) do
      render(conn, "show.json", locale: locale)
    end
  end

  def update(conn, %{"id" => id, "locale" => locale_params}) do
    with %Locale{} = locale <- Translations.get_locale!(id),
         {:ok, %Locale{} = locale} <- Translations.update_locale(locale, locale_params) do
      render(conn, "show.json", locale: locale)
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Locale{} = locale <- Translations.get_locale!(id),
         {:ok, %Locale{} = locale} <- Translations.safely_delete_locale(locale) do
      render(conn, "200.json")
    end
  end

  def keys_and_translations(conn, %{"locale_id" => id}) do
    render(conn, "keys_and_translations.json",
      keys_and_translations:
        Translations.get_locale_not_removed(id)
        |> Translations.get_keys_and_translations()
    )
  end

  def export(conn, %{"project_id" => project_id, "id" => locale_id}) do

  end

  def import(conn, %{"" => %Plug.Upload{} = file_params}) do
    {:ok, content} = File.read(file_params.path)
    [_, ext] = Regex.run(~r/\.(\w*)\z/, file_params.filename)

    with {:ok, _} <- Import.import_locale(conn.params["locale_id"], Parsers.parse(content, ext)) do
      render(conn, "200.json")
    end
  end
end
