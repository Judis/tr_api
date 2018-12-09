defmodule I18NAPI.Repo.Migrations.CreateUserRoles do
  use Ecto.Migration

  def change do
    create table(:user_roles) do
      add :role, :integer
      add :user_id, references(:users, on_delete: :delete_all)
      add :project_id, references(:projects, on_delete: :delete_all)

      timestamps()
    end

    create index(:user_roles, [:user_id])
    create index(:user_roles, [:project_id])
  end
end
