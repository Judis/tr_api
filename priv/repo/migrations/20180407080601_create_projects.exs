defmodule I18NAPI.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string
      add :is_removed, :boolean, default: false, null: false
      add :removed_at, :naive_datetime

      add :total_count_of_translation_keys, :integer, default: 0

      timestamps()
    end

  end
end

