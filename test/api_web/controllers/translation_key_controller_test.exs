defmodule I18NAPIWeb.TranslationKeyControllerTest do
  use I18NAPIWeb.ConnCase

  alias I18NAPI.Translations
  alias I18NAPI.Translations.TranslationKey

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(I18NAPI.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(I18NAPI.Repo, {:shared, self()})
    :ok
  end

  @create_attrs %{
    context: "some context",
    is_removed: true,
    key: "some key",
    removed_at: ~N[2010-04-17 14:00:00.000000],
    status: 42,
    value: "some value"
  }
  @update_attrs %{
    context: "some updated context",
    is_removed: false,
    key: "some updated key",
    removed_at: ~N[2011-05-18 15:01:01.000000],
    status: 43,
    value: "some updated value"
  }
  @invalid_attrs %{
    context: nil,
    is_removed: nil,
    key: nil,
    removed_at: nil,
    status: nil,
    value: nil
  }

  def fixture(:translation_key) do
    {:ok, translation_key} = Translations.create_translation_key(@create_attrs)
    translation_key
  end

  def fixture(:project) do
    {:ok, project} = Projects.create_project(@create_attrs)
    project
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all translation_keys", %{conn: conn} do
      conn = get(conn, project_translation_key_path(conn, :index, fixture(:project)))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create translation_key" do
    test "renders translation_key when data is valid", %{conn: conn} do
      conn =
        post(conn, project_translation_key_path(conn, :create, fixture(:project)),
          translation_key: @create_attrs
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, project_translation_key_path(conn, :show, fixture(:project), id))

      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "context" => "some context",
               "is_removed" => true,
               "key" => "some key",
               "removed_at" => ~N[2010-04-17 14:00:00.000000],
               "status" => 42,
               "value" => "some value"
             }
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, project_translation_key_path(conn, :create, fixture(:project)),
          translation_key: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update translation_key" do
    setup [:create_translation_key]

    test "renders translation_key when data is valid", %{
      conn: conn,
      translation_key: %TranslationKey{id: id} = translation_key
    } do
      conn =
        put(
          conn,
          project_translation_key_path(conn, :update, fixture(:project), translation_key),
          translation_key: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, project_translation_key_path(conn, :show, fixture(:project), id))

      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "context" => "some updated context",
               "is_removed" => false,
               "key" => "some updated key",
               "removed_at" => ~N[2011-05-18 15:01:01.000000],
               "status" => 43,
               "value" => "some updated value"
             }
    end

    test "renders errors when data is invalid", %{conn: conn, translation_key: translation_key} do
      conn =
        put(
          conn,
          project_translation_key_path(conn, :update, fixture(:project), translation_key),
          translation_key: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete translation_key" do
    setup [:create_translation_key]

    test "deletes chosen translation_key", %{conn: conn, translation_key: translation_key} do
      conn =
        delete(
          conn,
          project_translation_key_path(conn, :delete, fixture(:project), translation_key)
        )

      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, project_translation_key_path(conn, :show, fixture(:project), translation_key))
      end)
    end
  end

  defp create_translation_key(_) do
    translation_key = fixture(:translation_key)
    {:ok, translation_key: translation_key}
  end
end
