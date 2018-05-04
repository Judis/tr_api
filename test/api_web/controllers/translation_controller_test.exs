defmodule I18NAPIWeb.TranslationControllerTest do
  # use I18NAPIWeb.ConnCase

  # alias I18NAPI.Translations
  # alias I18NAPI.Translations.Translation

  # @create_attrs %{
  #   is_removed: true,
  #   removed_at: ~N[2010-04-17 14:00:00.000000],
  #   value: "some value"
  # }
  # @update_attrs %{
  #   is_removed: false,
  #   removed_at: ~N[2011-05-18 15:01:01.000000],
  #   value: "some updated value"
  # }
  # @invalid_attrs %{is_removed: nil, removed_at: nil, value: nil}

  # def fixture(:translation) do
  #   {:ok, translation} = Translations.create_translation(@create_attrs)
  #   translation
  # end

  # setup %{conn: conn} do
  #   {:ok, conn: put_req_header(conn, "accept", "application/json")}
  # end

  # describe "index" do
  #   test "lists all translations", %{conn: conn} do
  #     conn = get(conn, translation_path(conn, :index))
  #     assert json_response(conn, 200)["data"] == []
  #   end
  # end

  # describe "create translation" do
  #   test "renders translation when data is valid", %{conn: conn} do
  #     conn = post(conn, translation_path(conn, :create), translation: @create_attrs)
  #     assert %{"id" => id} = json_response(conn, 201)["data"]

  #     conn = get(conn, translation_path(conn, :show, id))

  #     assert json_response(conn, 200)["data"] == %{
  #              "id" => id,
  #              "is_removed" => true,
  #              "removed_at" => ~N[2010-04-17 14:00:00.000000],
  #              "value" => "some value"
  #            }
  #   end

  #   test "renders errors when data is invalid", %{conn: conn} do
  #     conn = post(conn, translation_path(conn, :create), translation: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "update translation" do
  #   setup [:create_translation]

  #   test "renders translation when data is valid", %{
  #     conn: conn,
  #     translation: %Translation{id: id} = translation
  #   } do
  #     conn = put(conn, translation_path(conn, :update, translation), translation: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get(conn, translation_path(conn, :show, id))

  #     assert json_response(conn, 200)["data"] == %{
  #              "id" => id,
  #              "is_removed" => false,
  #              "removed_at" => ~N[2011-05-18 15:01:01.000000],
  #              "value" => "some updated value"
  #            }
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, translation: translation} do
  #     conn = put(conn, translation_path(conn, :update, translation), translation: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete translation" do
  #   setup [:create_translation]

  #   test "deletes chosen translation", %{conn: conn, translation: translation} do
  #     conn = delete(conn, translation_path(conn, :delete, translation))
  #     assert response(conn, 204)

  #     assert_error_sent(404, fn ->
  #       get(conn, translation_path(conn, :show, translation))
  #     end)
  #   end
  # end

  # defp create_translation(_) do
  #   translation = fixture(:translation)
  #   {:ok, translation: translation}
  # end
end
