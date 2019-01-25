defmodule I18NAPIWeb.TranslationKeyControllerTest do
  use ExUnit.Case, async: false
  @moduletag :translation_key_controller

  use I18NAPIWeb.ConnCase
  use I18NAPI.Fixtures, [:setup_with_auth, :user, :project, :translation_key]

  alias I18NAPI.Translations
  alias I18NAPI.Translations.{TranslationKey}

  import Ecto.Query, warn: false

  describe "index" do
    setup [:project]

    test "lists all translation_keys", %{conn: conn, project: project} do
      conn = get(conn, project_translation_key_path(conn, :index, project.id))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create translation_key" do
    setup [:project]

    test "renders translation_key when data is valid", %{conn: conn, project: project} do
      conn =
        post(conn, project_translation_key_path(conn, :create, project.id),
          translation_key: attrs(:translation_key)
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      result_key = Translations.get_translation_key!(id)
      assert %TranslationKey{} = result_key
      assert result_key.key == attrs(:translation_key).key
      assert result_key.default_value == attrs(:translation_key).default_value
      assert result_key.context == attrs(:translation_key).context
      assert result_key.is_removed == attrs(:translation_key).is_removed
    end

    test "renders errors when data is invalid", %{conn: conn, project: project} do
      conn =
        post(conn, project_translation_key_path(conn, :create, project.id),
          translation_key: attrs(:translation_key_nil)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update translation_key" do
    setup [:project, :translation_key]

    test "renders translation_key when data is valid", %{
      conn: conn,
      project: project,
      translation_key: translation_key
    } do
      conn =
        put(conn, project_translation_key_path(conn, :update, project.id, translation_key),
          translation_key: attrs(:translation_key_alter)
        )

      assert %{"id" => id} = json_response(conn, 200)["data"]

      result_key = Translations.get_translation_key!(id)
      assert %TranslationKey{} = result_key
      assert result_key.key == attrs(:translation_key_alter).key
      assert result_key.default_value == attrs(:translation_key_alter).default_value
      assert result_key.context == attrs(:translation_key_alter).context
      assert result_key.is_removed == attrs(:translation_key_alter).is_removed
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      project: project,
      translation_key: translation_key
    } do
      conn =
        put(conn, project_translation_key_path(conn, :update, project.id, translation_key),
          translation_key: attrs(:translation_key_nil)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete translation_key" do
    setup [:project, :translation_key]

    test "deletes chosen translation_key", %{
      conn: conn,
      project: _,
      translation_key: translation_key
    } do
      response =
        delete(
          conn,
          project_translation_key_path(conn, :delete, translation_key.project_id, translation_key)
        )

      assert json_response(response, 200)["success"]

      no_content_response =
        get(
          conn,
          project_translation_key_path(conn, :show, translation_key.project_id, translation_key)
        )

      assert response(no_content_response, 204)
    end
  end

  defp project(%{conn: conn}), do: {:ok, project: fixture(:project, user: conn.user)}

  defp translation_key(%{conn: conn}) do
    {:ok,
     translation_key:
       fixture(:translation_key, %{project_id: fixture(:project, user: conn.user).id})}
  end
end
