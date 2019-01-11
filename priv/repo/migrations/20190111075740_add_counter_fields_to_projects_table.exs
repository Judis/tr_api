defmodule I18NAPI.Repo.Migrations.AddCounterFieldsToProjectsTable do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :total_count_of_translation_keys, :integer, default: 0
      add :count_of_not_verified_keys, :integer, default: 0
      add :count_of_verified_keys, :integer, default: 0
      add :count_of_translated_keys, :integer, default: 0
      add :count_of_untranslated_keys, :integer, default: 0
      add :count_of_keys_need_check, :integer, default: 0
    end
  end
end
