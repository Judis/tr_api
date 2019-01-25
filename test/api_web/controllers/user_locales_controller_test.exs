defmodule I18NAPIWeb.UserLocaleControllerTest do
  use ExUnit.Case, async: false
  @moduletag :user_locale_controller

  use I18NAPIWeb.ConnCase
  use I18NAPI.Fixtures, [:setup_with_auth, :user, :project, :locale, :user_locale]

  import Ecto.Query, warn: false

  describe "index" do
    setup [:project, :locale]

    test "lists all user_locales", %{conn: conn, project: project, locale: locale} do
      conn = get(conn, project_locale_user_locale_path(conn, :index, project.id, locale.id))
      assert json_response(conn, 200)["data"]
    end
  end

  describe "create user_locale" do
    setup [:project, :locale]

    test "renders user_locale when data is valid", %{
      conn: conn,
      project: project,
      locale: locale
    } do
      result_conn =
        post(conn, project_locale_user_locale_path(conn, :create, project.id, locale.id),
          user_locale: attrs(:user_locale)
        )

      assert %{"id" => id} = json_response(result_conn, 201)["data"]

      conn = get(conn, project_locale_user_locale_path(conn, :show, project.id, locale.id, id))
      assert %{"id" => id} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, project: project, locale: locale} do
      conn =
        post(conn, project_locale_user_locale_path(conn, :create, project.id, locale.id),
          user_locale: attrs(:user_locale_nil)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user_locale" do
    setup [:project, :locale]

    test "renders user_locale when data is valid", %{conn: conn, project: project} do
      locale = fixture(:locale, %{project_id: project.id})
      user_locale = fixture(:user_locale, %{user_id: conn.user.id, locale_id: locale.id})

      result_conn =
        put(
          conn,
          project_locale_user_locale_path(conn, :update, project.id, locale.id, user_locale),
          user_locale: attrs(:user_locale_alter)
        )

      assert %{"id" => id} = json_response(result_conn, 200)["data"]

      conn = get(conn, project_locale_user_locale_path(conn, :show, project.id, locale.id, id))
      assert %{"id" => id} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, project: project} do
      locale = fixture(:locale, %{project_id: project.id})
      user_locale = fixture(:user_locale, %{user_id: conn.user.id, locale_id: locale.id})

      conn =
        put(
          conn,
          project_locale_user_locale_path(conn, :update, project.id, locale.id, user_locale),
          user_locale: attrs(:user_locale_nil)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user_locale" do
    setup [:project]

    test "deletes chosen user_locale", %{conn: conn, project: project} do
      locale = fixture(:locale, %{project_id: project.id})
      user_locale = fixture(:user_locale, %{user_id: conn.user.id, locale_id: locale.id})

      result_conn =
        delete(
          conn,
          project_locale_user_locale_path(conn, :delete, project.id, locale.id, user_locale)
        )

      assert json_response(result_conn, 200)["success"]

      result_conn =
        get(
          conn,
          project_locale_user_locale_path(conn, :show, project.id, locale.id, user_locale)
        )

      assert response(result_conn, 204)
    end
  end

  defp project(%{conn: conn}), do: {:ok, project: fixture(:project, user: conn.user)}

  defp locale(%{conn: conn}) do
    {:ok, locale: fixture(:locale, %{project_id: fixture(:project, user: conn.user).id})}
  end
end
