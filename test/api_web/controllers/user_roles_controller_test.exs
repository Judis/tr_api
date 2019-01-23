defmodule I18NAPIWeb.UserRoleControllerTest do
  use ExUnit.Case, async: true
  @moduletag :user_role_controller

  use I18NAPIWeb.ConnCase
  use I18NAPI.Fixtures, [:setup_with_auth, :user, :project, :user_role]
  
  alias I18NAPI.Projects
  alias I18NAPI.Projects.UserRole


  describe "index" do
   # setup[:project]
    test "lists all user_roles", %{conn: conn, project: project} do
      conn = get(conn, project_user_role_path(conn, :index, project.id))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user_role" do
    test "renders user_role when data is valid", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      user = fixture(:user_alter)
      conn =
        post(conn, project_user_role_path(conn, :create, project.id),
          user_role: attrs(:user_role)
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, project_user_role_path(conn, :show, id))
      assert json_response(conn, 200)["data"] == %{"id" => id, "role" => 0}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      conn = post(conn, project_user_role_path(conn, :create, project.id), user_role: attrs(:user_role_invalid))
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user_role" do

    test "renders user_role when data is valid", %{
      conn: conn,
      user_role: %UserRole{id: id} = user_role
    } do
      project = fixture(:project, user: conn.user)
      conn = put(conn, project_user_role_path(conn, :update, project.id, user_role), user_role: attrs(:user_role_manager))
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, project_user_role_path(conn, :show, id))
      assert json_response(conn, 200)["data"] == %{"id" => id, "role" => 1}
    end

    test "renders errors when data is invalid", %{conn: conn, user_role: user_role} do
      project = fixture(:project, user: conn.user)
      conn = put(conn, project_user_role_path(conn, :update, project.id, user_role), user_role: attrs(:user_role_invalid))
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user_role" do

    test "deletes chosen user_role", %{conn: conn, user_role: user_role} do
      project = fixture(:project, user: conn.user)
      conn = delete(conn, project_user_role_path(conn, :delete, project.id, user_role))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, project_user_role_path(conn, :show, project.id, user_role))
      end)
    end
  end
#defp project(%{conn: conn}), do:      {:ok, project: fixture(:project, user: conn.user)}
end
