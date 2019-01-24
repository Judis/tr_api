defmodule I18NAPIWeb.ProjectControllerTest do
  use ExUnit.Case, async: false
  @moduletag :project_controller

  use I18NAPIWeb.ConnCase
  use I18NAPI.Fixtures, [:setup_with_auth, :user, :project, :translation_key]

  alias I18NAPI.Accounts
  alias I18NAPI.Projects
  alias I18NAPI.Projects.Project
  alias I18NAPI.Translations.Statistics

  describe "index" do
    test "lists all projects", %{conn: conn} do
      conn = get(conn, project_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "show project" do
    setup [:project]

    test "render project when data is valid", %{conn: conn, project: project} do
      conn = get(conn, project_path(conn, :show, project.id))
      assert %{"id" => id} = json_response(conn, 200)["data"]

      project = Projects.get_project!(id)
      assert %Project{} = project
      assert project.name == attrs(:project).name
      assert project.default_locale == attrs(:project).default_locale
      assert project.total_count_of_translation_keys == 0
      assert project.count_of_not_verified_keys == 0
      assert project.count_of_verified_keys == 0
      assert project.count_of_translated_keys == 0
      assert project.count_of_untranslated_keys == 0
    end

    test "render project when data is valid with additional stats", %{
      conn: conn,
      project: project
    } do
      fixture(:translation_key, %{project_id: project.id})

      Statistics.update_all_project_counts(project.id)

      conn = get(conn, project_path(conn, :show, project.id))
      assert %{"id" => id} = json_response(conn, 200)["data"]

      project = Projects.get_project!(id)
      assert %Project{} = project
      assert project.name == attrs(:project).name
      assert project.default_locale == attrs(:project).default_locale
      assert project.total_count_of_translation_keys == 1
      assert project.count_of_not_verified_keys == 0
      assert project.count_of_verified_keys == 0
      # because default translation is
      assert project.count_of_translated_keys == 1
      assert project.count_of_untranslated_keys == 0
    end
  end

  describe "create project" do
    setup [:project]

    test "renders project when data is valid", %{conn: conn} do
      conn = post(conn, project_path(conn, :create), project: attrs(:project))
      assert %{"id" => id} = json_response(conn, 201)["data"]

      project = Projects.get_project!(id)
      assert %Project{} = project
      assert project.name == attrs(:project).name
      assert project.default_locale == attrs(:project).default_locale
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, project_path(conn, :create), project: attrs(:project_nil))
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update project" do
    setup [:project]

    test "renders project when data is valid", %{conn: conn, project: project} do
      conn = put(conn, project_path(conn, :update, project), project: attrs(:project_alter))
      assert %{"id" => id} = json_response(conn, 200)["data"]

      project = Projects.get_project!(project.id)
      assert %Project{} = project
      assert project.name == attrs(:project_alter).name
      assert project.default_locale == attrs(:project_alter).default_locale
    end

    test "renders errors when data is invalid", %{conn: conn, project: project} do
      conn = put(conn, project_path(conn, :update, project), project: attrs(:project_nil))
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete project" do
    setup [:project]

    test "deletes chosen project", %{conn: conn, project: project} do
      no_content_response = delete(conn, project_path(conn, :delete, project))
      assert json_response(no_content_response, 200)["success"]

      no_content_response = get(conn, project_path(conn, :show, project.id))
      assert response(no_content_response, 204)
    end
  end

  defp project(%{conn: conn}), do: {:ok, project: fixture(:project, user: conn.user)}
end
