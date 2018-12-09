defmodule I18NAPI.Repo.Migrations.CreateUserLocales do
  use Ecto.Migration

  def change do
    create table(:user_locales) do
      add :role, :integer
      add :user_id, references(:users, on_delete: :delete_all)
      add :locale_id, references(:locales, on_delete: :delete_all)

      timestamps()
    end

    create index(:user_locales, [:user_id])
    create index(:user_locales, [:locale_id])
  end
end
