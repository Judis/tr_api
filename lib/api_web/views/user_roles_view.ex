defmodule I18NAPIWeb.UserRoleView do
  use I18NAPIWeb, :view
  alias I18NAPIWeb.UserRoleView

  def render("index.json", %{user_roles: user_roles}) do
    %{data: render_many(user_roles, UserRoleView, "user_roles.json")}
  end

  def render("show.json", %{user_roles: user_roles}) do
    %{data: render_one(user_roles, UserRoleView, "user_roles.json")}
  end

  def render("user_roles.json", %{user_roles: user_roles}) do
    %{
      id: user_roles.id,
      role: user_roles.role,
      project_id: user_roles.project_id,
      user_id: user_roles.user_id
    }
  end
end
