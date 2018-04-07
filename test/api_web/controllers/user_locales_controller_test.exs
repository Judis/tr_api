defmodule I18NAPIWeb.UserLocalesControllerTest do
  use I18NAPIWeb.ConnCase

  alias I18NAPI.Projects
  alias I18NAPI.Projects.UserLocales

  @create_attrs %{role: 42}
  @update_attrs %{role: 43}
  @invalid_attrs %{role: nil}

  def fixture(:user_locales) do
    {:ok, user_locales} = Projects.create_user_locales(@create_attrs)
    user_locales
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all user_locales", %{conn: conn} do
      conn = get conn, user_locales_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user_locales" do
    test "renders user_locales when data is valid", %{conn: conn} do
      conn = post conn, user_locales_path(conn, :create), user_locales: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, user_locales_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "role" => 42}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_locales_path(conn, :create), user_locales: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user_locales" do
    setup [:create_user_locales]

    test "renders user_locales when data is valid", %{conn: conn, user_locales: %UserLocales{id: id} = user_locales} do
      conn = put conn, user_locales_path(conn, :update, user_locales), user_locales: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, user_locales_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "role" => 43}
    end

    test "renders errors when data is invalid", %{conn: conn, user_locales: user_locales} do
      conn = put conn, user_locales_path(conn, :update, user_locales), user_locales: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user_locales" do
    setup [:create_user_locales]

    test "deletes chosen user_locales", %{conn: conn, user_locales: user_locales} do
      conn = delete conn, user_locales_path(conn, :delete, user_locales)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, user_locales_path(conn, :show, user_locales)
      end
    end
  end

  defp create_user_locales(_) do
    user_locales = fixture(:user_locales)
    {:ok, user_locales: user_locales}
  end
end
