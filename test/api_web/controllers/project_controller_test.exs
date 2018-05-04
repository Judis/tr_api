defmodule I18NAPIWeb.ProjectControllerTest do
  # use I18NAPIWeb.ConnCase

  # alias I18NAPI.Projects
  # alias I18NAPI.Projects.Project

  # @create_attrs %{is_removed: true, name: "some name", removed_at: ~N[2010-04-17 14:00:00.000000]}
  # @update_attrs %{
  #   is_removed: false,
  #   name: "some updated name",
  #   removed_at: ~N[2011-05-18 15:01:01.000000]
  # }
  # @invalid_attrs %{is_removed: nil, name: nil, removed_at: nil}

  # def fixture(:project) do
  #   {:ok, project} = Projects.create_project(@create_attrs)
  #   project
  # end

  # setup %{conn: conn} do
  #   {:ok, conn: put_req_header(conn, "accept", "application/json")}
  # end

  # describe "index" do
  #   test "lists all projects", %{conn: conn} do
  #     conn = get(conn, project_path(conn, :index))
  #     assert json_response(conn, 200)["data"] == []
  #   end
  # end

  # describe "create project" do
  #   test "renders project when data is valid", %{conn: conn} do
  #     conn = post(conn, project_path(conn, :create), project: @create_attrs)
  #     assert %{"id" => id} = json_response(conn, 201)["data"]

  #     conn = get(conn, project_path(conn, :show, id))

  #     assert json_response(conn, 200)["data"] == %{
  #              "id" => id,
  #              "is_removed" => true,
  #              "name" => "some name",
  #              "removed_at" => ~N[2010-04-17 14:00:00.000000]
  #            }
  #   end

  #   test "renders errors when data is invalid", %{conn: conn} do
  #     conn = post(conn, project_path(conn, :create), project: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "update project" do
  #   setup [:create_project]

  #   test "renders project when data is valid", %{conn: conn, project: %Project{id: id} = project} do
  #     conn = put(conn, project_path(conn, :update, project), project: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get(conn, project_path(conn, :show, id))

  #     assert json_response(conn, 200)["data"] == %{
  #              "id" => id,
  #              "is_removed" => false,
  #              "name" => "some updated name",
  #              "removed_at" => ~N[2011-05-18 15:01:01.000000]
  #            }
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, project: project} do
  #     conn = put(conn, project_path(conn, :update, project), project: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete project" do
  #   setup [:create_project]

  #   test "deletes chosen project", %{conn: conn, project: project} do
  #     conn = delete(conn, project_path(conn, :delete, project))
  #     assert response(conn, 204)

  #     assert_error_sent(404, fn ->
  #       get(conn, project_path(conn, :show, project))
  #     end)
  #   end
  # end

  # defp create_project(_) do
  #   project = fixture(:project)
  #   {:ok, project: project}
  # end
end
