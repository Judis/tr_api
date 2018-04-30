defmodule I18NAPI.Repo.Migrations.AddLocalesIndex do
  use Ecto.Migration

  def up do
    create unique_index(:locales, [:project_id, :locale])
  end

  def down do
    drop_if_exists unique_index(:locales, [:project_id, :locale])
  end
end
