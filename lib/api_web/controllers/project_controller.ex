defmodule I18NAPIWeb.ProjectController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Projects
  alias I18NAPI.Projects.Project

  action_fallback(I18NAPIWeb.FallbackController)

  def index(conn, _params) do
    render(conn, "index.json",
      projects: Projects.list_projects_not_removed(conn.private[:guardian_default_resource].id)
    )
  end

  def create(conn, %{"project" => project_params}) do
    with {:ok, %Project{} = project} <-
           Projects.create_project(project_params, conn.private[:guardian_default_resource]) do
      conn
      |> put_status(:created)
      |> render("show.json", project: project)
    end
  end

  def show(conn, %{"id" => id}) do
    with %Project{} = project <- Projects.get_project_not_removed(id) do
      render(conn, "show.json", project: project)
    end
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    with {:ok, %Project{} = project} <-
           Projects.get_project!(id) |> Projects.update_project(project_params) do
      render(conn, "show.json", project: project)
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Project{} = project <- Projects.get_project!(id),
         {:ok, %Project{} = project} <- Projects.safely_delete_project(project) do
      render(conn, "200.json")
    end
  end
end
