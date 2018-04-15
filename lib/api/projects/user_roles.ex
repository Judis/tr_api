defmodule I18NAPI.Projects.UserRoles do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_roles" do
    field(:role, :integer)
    field(:user_id, :id)
    field(:project_id, :id)

    timestamps()
  end

  @doc false
  def changeset(user_roles, attrs) do
    user_roles
    |> cast(attrs, [:role])
    |> validate_required([:role])
  end
end
