defmodule I18NAPI.Repo.Migrations.AddLocalesIndexByRemoved do
  use Ecto.Migration

  def up do
    create unique_index(:locales, [:project_id, :locale, :is_removed])
    drop_if_exists unique_index(:locales, [:project_id, :locale])
  end

  def down do
    drop_if_exists unique_index(:locales, [:project_id, :locale, :is_removed])
  end
end
