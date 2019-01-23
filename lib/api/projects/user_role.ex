defmodule I18NAPI.Projects.UserRole do
  use Ecto.Schema
  import Ecto.Changeset
  alias I18NAPI.Projects.UserRole
  alias I18NAPI.Utilities

  schema "user_roles" do
    field(:role, RoleEnum)
    field(:is_removed, :boolean, default: false)
    field(:removed_at, :naive_datetime)

    belongs_to(:user, I18NAPI.Accounts.User)
    belongs_to(:project, I18NAPI.Projects.Project)

    timestamps()
  end

  @doc false
  def changeset(user_role, attrs) do
    user_role
    |> cast(attrs, [:role, :project_id, :user_id])
    |> validate_required([:role, :project_id, :user_id])
    |> unique_constraint_if_active()
  end

  defp unique_constraint_if_active(changeset) do
    new_error = [{:user_project_remove_constraint, "Duplicated active user_role"}]

    with true <- Map.has_key?(changeset.changes, :project_id),
         true <- Map.has_key?(changeset.changes, :user_id),
         true <- Map.has_key?(changeset.data, :id),
         %UserRole{} <-
           I18NAPI.Projects.get_user_role_non_removed_but_not_this(
             changeset.changes.project_id,
             changeset.changes.user_id,
             changeset.data.id
           ) do
      %{changeset | errors: new_error ++ changeset.errors, valid?: false}
    else
      _ -> changeset
    end
  end

  @doc false
  def remove_changeset(project) do
    project
    |> cast(%{is_removed: true, removed_at: Utilities.get_utc_now()}, [:is_removed, :removed_at])
    |> validate_required([:is_removed, :removed_at])
  end
end
