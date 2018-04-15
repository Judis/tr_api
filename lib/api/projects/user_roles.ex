defmodule I18NAPI.Projects.UserRoles do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_roles" do
    field(:role, :integer)

    belongs_to(:user, I18NAPI.Accounts.User)
    belongs_to(:project, I18NAPI.Projects.Project)

    timestamps()
  end

  @doc false
  def changeset(user_roles, attrs) do
    user_roles
    |> cast(attrs, [:role, :project_id, :user_id])
    |> validate_required([:role, :project_id, :user_id])
  end
end
