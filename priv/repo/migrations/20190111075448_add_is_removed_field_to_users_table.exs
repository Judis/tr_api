defmodule I18NAPI.Repo.Migrations.AddIsRemovedFieldToUsersTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_removed, :boolean, default: false, null: false
      add :removed_at, :naive_datetime
    end
  end
end
