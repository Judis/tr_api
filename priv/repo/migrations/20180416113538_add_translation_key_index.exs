defmodule I18NAPI.Repo.Migrations.AddTranslationKeyIndex do
  use Ecto.Migration

  def up do
    create unique_index(:translation_keys, [:locale_id, :key, :is_removed])
  end

  def down do
    drop_if_exists unique_index(:translation_keys, [:locale_id, :key, :is_removed])
  end
end
