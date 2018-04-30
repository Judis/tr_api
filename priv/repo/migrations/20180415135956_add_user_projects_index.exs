defmodule I18NAPI.Repo.Migrations.AddUserProjectsIndex do
  use Ecto.Migration

  def up do
    create unique_index(:user_roles, [:user_id, :project_id])
  end

  def down do
    drop_if_exists unique_index(:user_roles, [:user_id, :project_id])
  end
end
