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
      |> render("show.json", user_role: user_role)
    end
  end

  def show(conn, %{"id" => id}) do
    with %UserRole{} = user_role <- Projects.get_user_role!(id) do
      case user_role.is_removed do
        false -> render(conn, "show.json", user_role: user_role)
        _ -> {:error, :no_content}
      end
    end
  end

  def update(conn, %{"id" => id, "user_role" => user_role_params}) do
    user_role = Projects.get_user_role!(id)

    with {:ok, %UserRole{} = user_role} <-
           Projects.update_user_role(user_role, user_role_params) do
      case user_role.is_removed do
        false -> render(conn, "show.json", user_role: user_role)
        _ -> {:error, :no_content}
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    user_role = Projects.get_user_role!(id)

    with {:ok, %UserRole{} = user_role} <- Projects.safely_delete_user_role(user_role) do
      case user_role.is_removed do
        false -> render(conn, "show.json", user_role: user_role)
        _ -> {:error, :no_content}
      end
    end
  end
end
