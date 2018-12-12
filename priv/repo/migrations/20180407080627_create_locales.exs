defmodule I18NAPI.Repo.Migrations.CreateLocales do
  use Ecto.Migration

  def change do
    create table(:locales) do
      add :locale, :string
      add :is_default, :boolean, default: false, null: false
      add :count_of_keys, :integer
      add :count_of_words, :integer
      add :count_of_translated_keys, :integer
      add :is_removed, :boolean, default: false, null: false
      add :removed_at, :naive_datetime
      add :project_id, references(:projects, on_delete: :nothing)

      add :total_count_of_translation_keys, :integer, default: 0
      add :count_of_not_verified_keys, :integer, default: 0
      add :count_of_verified_keys, :integer, default: 0
      add :count_of_translated_keys, :integer, default: 0
      add :count_of_untranslated_keys, :integer, default: 0
      add :count_of_keys_need_check, :integer, default: 0

      timestamps()
    end

    create index(:locales, [:project_id])
  end
end
