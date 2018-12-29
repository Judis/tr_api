defmodule I18NAPIWeb.ProjectController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Projects
  alias I18NAPI.Projects.Project

  action_fallback(I18NAPIWeb.FallbackController)

  def index(conn, _params) do
    projects = Projects.list_projects(conn.private[:guardian_default_resource].id)
    render(conn, "index.json", projects: projects)
  end

  def create(conn, %{"project" => project_params}) do
    with {:ok, %Project{} = project} <-
           Projects.create_project(project_params, conn.private[:guardian_default_resource]) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", project_path(conn, :show, project))
      |> render("show.json", project: project)
    end
  end

  def show(conn, %{"id" => id}) do
    project = Projects.get_project!(id)

    case project.is_removed do
      false -> render(conn, "show.json", project: project)
      _ -> conn |> put_status(204) |> render("204.json")
    end
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Projects.get_project!(id)

    with {:ok, %Project{} = project} <- Projects.update_project(project, project_params) do
      case project.is_removed do
        false -> render(conn, "show.json", project: project)
        _ -> conn |> put_status(204) |> render("204.json")
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Projects.get_project!(id)

    with {:ok, %Project{} = project} <- Projects.safely_delete_project(project) do
      case project.is_removed do
        false -> render(conn, "show.json", project: project)
        _ -> conn |> put_status(204) |> render("204.json")
      end
    end
  end
end
