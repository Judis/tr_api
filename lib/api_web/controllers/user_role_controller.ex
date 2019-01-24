defmodule I18NAPIWeb.UserRoleController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Projects
  alias I18NAPI.Projects.UserRole

  action_fallback(I18NAPIWeb.FallbackController)

  def index(conn, _params) do
    render(conn, "index.json", user_role: Projects.list_user_roles())
  end

  def create(conn, %{"user_role" => user_role_params}) do
    with {:ok, %UserRole{} = user_role} <- Projects.create_user_role(user_role_params) do
      conn
      |> put_status(:created)
      |> render("show.json", user_role: user_role)
    end
  end

  def show(conn, %{"id" => id}) do
    with %UserRole{} = user_role <- Projects.get_user_role_non_removed(id) do
      render(conn, "show.json", user_role: user_role)
    end
  end

  def update(conn, %{"id" => id, "user_role" => user_role_params}) do
    with %UserRole{} = user_role <- Projects.get_user_role!(id),
         {:ok, %UserRole{} = user_role} <- Projects.update_user_role(user_role, user_role_params) do
      render(conn, "show.json", user_role: user_role)
    end
  end

  def delete(conn, %{"id" => id}) do
    with %UserRole{} = user_role <- Projects.get_user_role!(id),
         {:ok, %UserRole{} = user_role} <- Projects.safely_delete_user_role(user_role) do
      render(conn, "200.json")
    end
  end
end
