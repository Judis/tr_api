defmodule I18NAPI.Repo.Migrations.AddCounterFieldsToLocalesTable do
  use Ecto.Migration

  def change do
    alter table(:locales) do

      add :total_count_of_translation_keys, :integer, default: 0
      add :count_of_not_verified_keys, :integer, default: 0
      add :count_of_verified_keys, :integer, default: 0
      add :count_of_untranslated_keys, :integer, default: 0
      add :count_of_keys_need_check, :integer, default: 0

      modify :count_of_translated_keys, :integer, default: 0

      remove :count_of_keys
      remove :count_of_words
    end

  end
end
