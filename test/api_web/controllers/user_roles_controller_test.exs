defmodule I18NAPIWeb.UserRoleControllerTest do
  use ExUnit.Case, async: true
  @moduletag :user_role_controller

  use I18NAPIWeb.ConnCase
  use I18NAPI.Fixtures, [:setup_with_auth, :user, :project, :user_role]

  alias I18NAPI.Projects.UserRole

  describe "index" do
    setup [:project]

    test "lists all user_roles", %{conn: conn, project: project} do
      conn = get(conn, project_user_role_path(conn, :index, project.id))

      assert project.id ==
               json_response(conn, 200)["data"] |> List.first() |> Map.get("project_id")
    end
  end

  describe "create user_role" do
    setup [:user, :project]

    test "renders user_role when data is valid", %{conn: conn, user: user, project: project} do
      attrs = attrs(:user_role) |> Map.put(:project_id, project.id) |> Map.put(:user_id, user.id)

      result_conn =
        post(conn, project_user_role_path(conn, :create, project.id), user_role: attrs)

      assert %{"id" => id} = json_response(result_conn, 201)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user, project: project} do
      attrs =
        attrs(:user_role_invalid)
        |> Map.put(:project_id, project.id)
        |> Map.put(:user_id, user.id)

      result_conn =
        post(conn, project_user_role_path(conn, :create, project.id), user_role: attrs)

      assert json_response(result_conn, 422)["errors"] == %{"role" => ["is invalid"]}
    end
  end

  describe "update user_role" do
    setup [:project, :user_role]

    test "renders user_role when data is valid", %{
      conn: conn,
      project: project,
      user_role: %UserRole{id: id} = user_role
    } do
      conn =
        put(conn, project_user_role_path(conn, :update, project.id, user_role),
          user_role: attrs(:user_role_manager)
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user_role: user_role} do
      project = fixture(:project, user: conn.user)

      conn =
        put(conn, project_user_role_path(conn, :update, project.id, user_role),
          user_role: attrs(:user_role_invalid)
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user_role" do
    setup [:project, :user_role]

    test "deletes chosen user_role", %{conn: conn, project: project, user_role: user_role} do
      result_conn = delete(conn, project_user_role_path(conn, :delete, project.id, user_role))
      assert json_response(result_conn, 200)["success"]

      result_conn = get(conn, project_user_role_path(conn, :show, project.id, user_role.id))
      assert response(result_conn, 204)
    end
  end

  defp user(%{conn: _}), do: {:ok, user: fixture(:user_alter)}
  defp project(%{conn: conn}), do: {:ok, project: fixture(:project, user: conn.user)}

  defp user_role(%{conn: conn}) do
    {:ok,
     user_role:
       fixture(:user_role, %{
         user_id: conn.user.id,
         project_id: fixture(:project, user: conn.user).id
       })}
  end
end
