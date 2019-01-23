defmodule I18NAPI.Repo.Migrations.AddIsRemoveFieldsToUserRoles do
  use Ecto.Migration


  def up do
    alter table(:user_roles) do
      add :is_removed, :boolean, default: false, null: false
      add :removed_at, :naive_datetime
    end

    create index(:user_roles, [:user_id, :project_id, :is_removed], name: :user_project_removed_user_role_index)
    drop_if_exists unique_index(:user_roles, [:user_id, :project_id])
  end

  def down do
    alter table(:user_roles) do
      remove :is_removed
      remove :removed_at
    end

    drop_if_exists index(:user_roles, [:user_id, :project_id, :is_removed])
    create unique_index(:user_roles, [:user_id, :project_id])
  end
end
