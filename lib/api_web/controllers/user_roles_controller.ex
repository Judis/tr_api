defmodule I18NAPIWeb.UserRolesController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Projects
  alias I18NAPI.Projects.UserRoles

  action_fallback(I18NAPIWeb.FallbackController)

  def index(conn, _params) do
    user_roles = Projects.list_user_roles()
    render(conn, "index.json", user_roles: user_roles)
  end

  def create(conn, %{"user_roles" => user_roles_params}) do
    with {:ok, %UserRoles{} = user_roles} <- Projects.create_user_roles(user_roles_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_roles_path(conn, :show, user_roles))
      |> render("show.json", user_roles: user_roles)
    end
  end

  def show(conn, %{"id" => id}) do
    user_roles = Projects.get_user_roles!(id)
    render(conn, "show.json", user_roles: user_roles)
  end

  def update(conn, %{"id" => id, "user_roles" => user_roles_params}) do
    user_roles = Projects.get_user_roles!(id)

    with {:ok, %UserRoles{} = user_roles} <-
           Projects.update_user_roles(user_roles, user_roles_params) do
      render(conn, "show.json", user_roles: user_roles)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_roles = Projects.get_user_roles!(id)

    with {:ok, %UserRoles{}} <- Projects.delete_user_roles(user_roles) do
      send_resp(conn, :no_content, "")
    end
  end
end
