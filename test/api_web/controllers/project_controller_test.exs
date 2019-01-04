defmodule I18NAPIWeb.ProjectControllerTest do
  use ExUnit.Case, async: false
  @moduletag :project_controller

  use I18NAPIWeb.ConnCase

  alias I18NAPI.Accounts
  alias I18NAPI.Projects
  alias I18NAPI.Projects.Project

  @user_attrs %{
    name: "project_controller test name",
    email: "project_controller@email.test",
    password: "Qw!23456",
    password_confirmation: "Qw!23456",
    source: "project_controller test source"
  }

  def user_fixture(attrs \\ %{}) do
    {result, user} = Accounts.find_and_confirm_user(@user_attrs.email, @user_attrs.password)

    if :error == result do
      with {:ok, new_user} <- attrs |> Enum.into(@user_attrs) |> Accounts.create_user(),
           do: new_user
    else
      user
    end
  end

  @create_attrs %{
    name: "some name",
    default_locale: "en"
  }
  @update_attrs %{
    name: "some updated name",
    # not changed
    default_locale: "en"
  }
  @invalid_attrs %{is_removed: nil, name: nil, removed_at: nil}

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.checkout(I18NAPI.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(I18NAPI.Repo, {:shared, self()})

    user = user_fixture()
    {:ok, jwt, _claims} = I18NAPI.Guardian.encode_and_sign(user)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{jwt}")
      |> Map.put(:user, user)

    {:ok, conn: conn}
  end

  def project_fixture(conn) do
    {:ok, project} = @create_attrs |> Projects.create_project(conn.user)
    project
  end

  describe "index" do
    test "lists all projects", %{conn: conn} do
      conn = get(conn, project_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "show project" do
    test "render project when data is valid", %{conn: conn} do
      project = project_fixture(conn)
      conn = get(conn, project_path(conn, :show, project.id))
      assert %{"id" => id} = json_response(conn, 200)["data"]

      project = Projects.get_project!(id)
      assert %Project{} = project
      assert project.name == @create_attrs.name
      assert project.default_locale == @create_attrs.default_locale
    end
  end

  describe "create project" do
    test "renders project when data is valid", %{conn: conn} do
      conn = post(conn, project_path(conn, :create), project: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      project = Projects.get_project!(id)
      assert %Project{} = project
      assert project.name == @create_attrs.name
      assert project.default_locale == @create_attrs.default_locale
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, project_path(conn, :create), project: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update project" do
    test "renders project when data is valid", %{conn: conn} do
      project = project_fixture(conn)
      conn = put(conn, project_path(conn, :update, project), project: @update_attrs)
      assert %{"id" => id} = json_response(conn, 200)["data"]

      project = Projects.get_project!(project.id)
      assert %Project{} = project
      assert project.name == @update_attrs.name
      assert project.default_locale == @update_attrs.default_locale
    end

    test "renders errors when data is invalid", %{conn: conn} do
      project = project_fixture(conn)
      conn = put(conn, project_path(conn, :update, project), project: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete project" do
    test "deletes chosen project", %{conn: conn} do
      project = project_fixture(conn)
      no_content_response = delete(conn, project_path(conn, :delete, project))
      assert response(no_content_response, 204)

      no_content_response = get(conn, project_path(conn, :show, project.id))
      assert response(no_content_response, 204)
    end
  end
end
