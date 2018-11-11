defmodule I18NAPIWeb.ProjectControllerTest do
  use ExUnit.Case, async: true
  @moduletag :project_controller

  use I18NAPIWeb.ConnCase

  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User
  alias I18NAPI.Projects
  alias I18NAPI.Projects.Project

  @user_attrs %{
    name: "test name",
    email: "test@email.test",
    password: "Qw!23456",
    password_confirmation: "Qw!23456",
    source: "test source"
  }

  def user_fixture(attrs \\ %{}) do
    {result, user} = Accounts.find_and_confirm_user(@user_attrs.email, @user_attrs.password)

    if :error == result do
      {:ok, user} =
        attrs
        |> Enum.into(@user_attrs)
        |> Accounts.create_user()
    end

    user
  end

  setup %{conn: conn} do
    user = user_fixture()
    {:ok, jwt, _claims} = I18NAPI.Guardian.encode_and_sign(user)
    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{jwt}")

    {:ok, conn: conn}
  end

  @create_attrs %{
    name: "some name",
    default_locale: "en"
  }
  @update_attrs %{
    name: "some updated name",
    default_locale: "fr"
  }
  @invalid_attrs %{is_removed: nil, name: nil, removed_at: nil}

  def fixture(:project) do
    user = user_fixture()
    {:ok, project} = @create_attrs |> Projects.create_project(user)
    project
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all projects", %{conn: conn} do
      conn = get(conn, project_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create project" do
    test "renders project when data is valid", %{conn: conn} do
      conn = post(conn, project_path(conn, :create), project: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      assert Projects.get_project!(id) == @create_attrs
#      conn = get(conn, project_path(conn, :show, id))

#      assert json_response(conn, 200)["data"] == %{
#               "id" => id,
#               "is_removed" => true,
#               "name" => "some name",
#               "removed_at" => ~N[2010-04-17 14:00:00.000000]
#             }
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, project_path(conn, :create), project: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update project" do
    setup [:create_project]

    test "renders project when data is valid", %{conn: conn, project: %Project{id: id} = project} do
      conn = put(conn, project_path(conn, :update, project), project: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      assert Projects.get_project!(project.id) == @update_attrs

#      conn = get(conn, project_path(conn, :show, id))

#      assert json_response(conn, 200)["data"] == %{
#               "id" => id,
#               "is_removed" => false,
#               "name" => "some updated name",
#               "removed_at" => ~N[2011-05-18 15:01:01.000000]
#             }
    end

    test "renders errors when data is invalid", %{conn: conn, project: project} do
      conn = put(conn, project_path(conn, :update, project), project: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete project" do
    setup [:create_project]

    test "deletes chosen project", %{conn: conn, project: project} do
      conn = delete(conn, project_path(conn, :delete, project))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, project_path(conn, :show, project))
      end)
    end
  end

  defp create_project(_) do
    project = fixture(:project)
    {:ok, project: project}
  end
end
