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

      timestamps()
    end

    create index(:locales, [:project_id])
  end
end
