defmodule I18NAPIWeb.LocaleControllerTest do
  use ExUnit.Case, async: true
  @moduletag :locale_controller

  use I18NAPIWeb.ConnCase
  use I18NAPI.Fixtures, [:setup_with_auth, :user, :project, :locale]

  alias I18NAPI.Accounts
  alias I18NAPI.Translations
  alias I18NAPI.Translations.Locale

  import Ecto.Query, warn: false

  describe "index" do
    setup [:project]

    test "lists all locales", %{conn: conn, project: project} do
      conn = get(conn, project_locale_path(conn, :index, project.id))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create locale" do
    setup [:project, :locale]

    test "renders locale when data is valid", %{conn: conn, project: project} do
      conn = post(conn, project_locale_path(conn, :create, project.id), locale: attrs(:locale))
      assert %{"id" => id} = json_response(conn, 201)["data"]

      result_locale = Translations.get_locale!(id)
      assert %Locale{} = result_locale
      assert result_locale.locale == attrs(:locale).locale
      assert result_locale.is_default == attrs(:locale).is_default
    end

    test "renders errors when data is invalid", %{conn: conn, locale: locale} do
      conn =
        post(conn, project_locale_path(conn, :create, locale.project_id),
          locale: attrs(:locale_nil)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update locale" do
    setup [:locale]

    test "renders locale when data is valid", %{conn: conn, locale: locale} do
      conn =
        put(conn, project_locale_path(conn, :update, locale.project_id, locale),
          locale: attrs(:locale_alter)
        )

      assert %{"id" => id} = json_response(conn, 200)["data"]

      result_locale = Translations.get_locale!(locale.id)
      assert result_locale.locale == attrs(:locale_alter).locale
    end

    test "renders errors when data is invalid", %{conn: conn, locale: locale} do
      conn =
        put(conn, project_locale_path(conn, :update, locale.project_id, locale),
          locale: attrs(:locale_nil)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete locale" do
    setup [:locale]

    test "deletes chosen locale", %{conn: conn, locale: locale} do
      no_content_response =
        delete(conn, project_locale_path(conn, :delete, locale.project_id, locale))

      assert json_response(no_content_response, 200)["success"]

      no_content_response =
        get(conn, project_locale_path(conn, :show, locale.project_id, locale.id))

      assert response(no_content_response, 204)
    end
  end

  defp project(%{conn: conn}), do: {:ok, project: fixture(:project, user: conn.user)}

  defp locale(%{conn: conn}) do
    {:ok, locale: fixture(:locale, %{project_id: fixture(:project, user: conn.user).id})}
  end
end
