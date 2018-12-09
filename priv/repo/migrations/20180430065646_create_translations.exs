defmodule I18NAPI.Repo.Migrations.CreateTranslations do
  use Ecto.Migration

  def change do
    TranslationStatusEnum.create_type
    create table(:translations) do
      add :value, :text
      add :is_removed, :boolean, default: false, null: false
      add :removed_at, :naive_datetime
      add :status, TranslationStatusEnum.type()
      add :locale_id, references(:locales, on_delete: :delete_all)
      add :translation_key_id, references(:translation_keys, on_delete: :delete_all)

      timestamps()
    end

    create index(:translations, [:locale_id])
    create index(:translations, [:translation_key_id])
    create unique_index(:translations, [:locale_id, :translation_key_id, :is_removed], where: "is_removed = false")
  end
end
