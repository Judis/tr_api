defmodule I18NAPIWeb.UserRoleView do
  use I18NAPIWeb, :view
  alias I18NAPIWeb.UserRoleView

  def render("200.json", %{}) do
    %{success: true}
  end

  def render("index.json", %{user_role: user_role}) do
    %{data: render_many(user_role, UserRoleView, "user_role.json")}
  end

  def render("show.json", %{user_role: user_role}) do
    %{data: render_one(user_role, UserRoleView, "user_role.json")}
  end

  def render("user_role.json", %{user_role: user_role}) do
    %{
      id: user_role.id,
      role: user_role.role,
      project_id: user_role.project_id,
      user_id: user_role.user_id
    }
  end
end
