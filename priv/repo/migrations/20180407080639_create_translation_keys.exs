defmodule I18NAPI.Repo.Migrations.CreateTranslationKeys do
  use Ecto.Migration

  def change do
    create table(:translation_keys) do
      add :key, :string
      add :context, :text
      add :status, :integer
      add :is_removed, :boolean, default: false, null: false
      add :removed_at, :naive_datetime
      add :project_id, references(:projects, on_delete: :nothing)

      timestamps()
    end

    create index(:translation_keys, [:project_id])
  end
end
