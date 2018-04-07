defmodule I18NAPIWeb.UserRolesControllerTest do
  use I18NAPIWeb.ConnCase

  alias I18NAPI.Projects
  alias I18NAPI.Projects.UserRoles

  @create_attrs %{role: 42}
  @update_attrs %{role: 43}
  @invalid_attrs %{role: nil}

  def fixture(:user_roles) do
    {:ok, user_roles} = Projects.create_user_roles(@create_attrs)
    user_roles
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all user_roles", %{conn: conn} do
      conn = get conn, user_roles_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user_roles" do
    test "renders user_roles when data is valid", %{conn: conn} do
      conn = post conn, user_roles_path(conn, :create), user_roles: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, user_roles_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "role" => 42}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_roles_path(conn, :create), user_roles: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user_roles" do
    setup [:create_user_roles]

    test "renders user_roles when data is valid", %{conn: conn, user_roles: %UserRoles{id: id} = user_roles} do
      conn = put conn, user_roles_path(conn, :update, user_roles), user_roles: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, user_roles_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "role" => 43}
    end

    test "renders errors when data is invalid", %{conn: conn, user_roles: user_roles} do
      conn = put conn, user_roles_path(conn, :update, user_roles), user_roles: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user_roles" do
    setup [:create_user_roles]

    test "deletes chosen user_roles", %{conn: conn, user_roles: user_roles} do
      conn = delete conn, user_roles_path(conn, :delete, user_roles)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, user_roles_path(conn, :show, user_roles)
      end
    end
  end

  defp create_user_roles(_) do
    user_roles = fixture(:user_roles)
    {:ok, user_roles: user_roles}
  end
end
