defmodule I18NAPIWeb.UserRoleController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Projects
  alias I18NAPI.Projects.UserRole

  action_fallback(I18NAPIWeb.FallbackController)

  def index(conn, _params) do
    user_role = Projects.list_user_roles()
    render(conn, "index.json", user_role: user_role)
  end

  def create(conn, %{"user_role" => user_role_params}) do
    with {:ok, %UserRole{} = user_role} <- Projects.create_user_role(user_role_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", project_user_role_path(conn, :show, user_role))
      |> render("show.json", user_role: user_role)
    end
  end

  def show(conn, %{"id" => id}) do
    user_role = Projects.get_user_role!(id)
    render(conn, "show.json", user_role: user_role)
  end

  def update(conn, %{"id" => id, "user_role" => user_role_params}) do
    user_role = Projects.get_user_role!(id)

    with {:ok, %UserRole{} = user_role} <-
           Projects.update_user_role(user_role, user_role_params) do
      render(conn, "show.json", user_role: user_role)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_role = Projects.get_user_role!(id)

    with {:ok, %UserRole{}} <- Projects.delete_user_role(user_role) do
      send_resp(conn, :no_content, "")
    end
  end
end
