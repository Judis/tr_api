defmodule I18NAPI.Repo.Migrations.CreateTranslations do
  use Ecto.Migration

  def change do
    TranslationStatusEnum.create_type
    create table(:translations) do
      add :value, :text, default: nil
      add :status, TranslationStatusEnum.type()
      add :locale_id, references(:locales, on_delete: :delete_all)
      add :translation_key_id, references(:translation_keys, on_delete: :delete_all)

      timestamps()
    end

    create index(:translations, [:locale_id])
    create index(:translations, [:translation_key_id])
    create unique_index(:translations, [:locale_id, :translation_key_id])
  end
end
