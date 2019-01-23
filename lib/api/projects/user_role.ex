defmodule I18NAPI.Projects.UserRole do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_roles" do
    field(:role, RoleEnum)

    belongs_to(:user, I18NAPI.Accounts.User)
    belongs_to(:project, I18NAPI.Projects.Project)

    timestamps()
  end

  @doc false
  def changeset(user_role, attrs) do
    user_role
    |> cast(attrs, [:role, :project_id, :user_id])
    |> validate_required([:role, :project_id, :user_id])
    |> unique_constraint(:project_id, name: :user_roles_user_id_project_id_index)
  end
end
