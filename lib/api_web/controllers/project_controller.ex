defmodule I18NAPIWeb.ProjectController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Projects
  alias I18NAPI.Projects.Project

  action_fallback(I18NAPIWeb.FallbackController)

  def index(conn, _params) do
    projects = Projects.list_projects(conn.assigns[:user].id)
    render(conn, "index.json", projects: projects)
  end

  def create(conn, %{"project" => project_params}) do
    with {:ok, %Project{} = project} <-
           Projects.create_project(project_params, conn.assigns[:user]) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", project_path(conn, :show, project))
      |> render("show.json", project: project)
    end
  end

  def show(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    render(conn, "show.json", project: project)
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Projects.get_project!(id)

    with {:ok, %Project{} = project} <- Projects.update_project(project, project_params) do
      render(conn, "show.json", project: project)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Projects.get_project!(id)

    with {:ok, %Project{}} <- Projects.safely_delete_project(project) do
      render(conn, "show.json", project: project)
    end
  end
end
