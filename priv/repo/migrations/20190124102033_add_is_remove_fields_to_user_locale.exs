defmodule I18NAPI.Repo.Migrations.AddIsRemoveFieldsToUserRoles do
  use Ecto.Migration


  def up do
    alter table(:user_locales) do
      add :is_removed, :boolean, default: false, null: false
      add :removed_at, :naive_datetime
    end
  end

  def down do
    alter table(:user_locales) do
      remove :is_removed
      remove :removed_at
    end
  end
end
