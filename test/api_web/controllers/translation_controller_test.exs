defmodule I18NAPIWeb.TranslationControllerTest do
  use ExUnit.Case, async: true
  @moduletag :translation_controller

  use I18NAPIWeb.ConnCase

  alias I18NAPI.Translations
  alias I18NAPI.Translations.{Translation, Translations}

  @create_attrs %{
    is_removed: true,
    removed_at: ~N[2010-04-17 14:00:00.000000],
    value: "some value"
  }
  @update_attrs %{
    is_removed: false,
    removed_at: ~N[2011-05-18 15:01:01.000000],
    value: "some updated value"
  }
  @invalid_attrs %{is_removed: nil, removed_at: nil, value: nil}

  def fixture(param) do
    case param do
      :translation ->
        {:ok, translation} = Translations.create_translation(@create_attrs)
        translation

      :project ->
        {:ok, project} = Projects.create_project(@create_attrs)
        project
    end
  end

  def translation_fixture(attrs, locale_id, translation_key_id) do
    attrs = %{translation_key_id: translation_key_id}
            |> Enum.into(attrs)

    {:ok, translation} = Translations.create_translation(attrs, locale_id)

    translation
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all translations", %{conn: conn} do
      conn = get(conn, project_locale_translation_path(conn, :index, fixture(:project), fixture(:translation).locale_id, fixture(:translation)))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create translation" do
    test "renders translation when data is valid", %{conn: conn} do
      conn = post(conn, project_locale_translation_path(conn, :create, fixture(:project), fixture(:translation).locale_id, fixture(:translation)), translation: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, project_locale_translation_path(conn, :show, fixture(:project), fixture(:translation).locale_id, fixture(:translation), id))

      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "is_removed" => true,
               "removed_at" => ~N[2010-04-17 14:00:00.000000],
               "value" => "some value"
             }
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, project_locale_translation_path(conn, :create, fixture(:project), fixture(:translation).locale_id, fixture(:translation)), translation: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update translation" do
    setup [:create_translation]

    test "renders translation when data is valid", %{
      conn: conn,
      translation: %Translation{id: id} = translation
    } do
      conn = put(conn, project_locale_translation_path(conn, :update, fixture(:project), translation.locale_id, translation),
        translation: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn,
        project_locale_translation_path(conn, :show, fixture(:project), translation.locale_id, translation, id))

      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "is_removed" => false,
               "removed_at" => ~N[2011-05-18 15:01:01.000000],
               "value" => "some updated value"
             }
    end

    test "renders errors when data is invalid", %{conn: conn, translation: translation} do
      conn = put(conn,
        project_locale_translation_path(conn, :update, fixture(:project), translation.locale_id, translation, translation), translation: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete translation" do
    setup [:create_translation]

    test "deletes chosen translation", %{conn: conn, translation: translation} do
      conn = delete(conn, project_locale_translation_path(conn, :delete, fixture(:project), translation.locale_id, translation, translation))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
          get(conn, project_locale_translation_path(conn, :show, fixture(:project), translation.locale_id, translation, translation))
        end)
    end
  end

  defp create_translation(_) do
    translation = fixture(:translation)
    {:ok, translation: translation}
  end
end
