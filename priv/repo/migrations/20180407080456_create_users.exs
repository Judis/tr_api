defmodule I18NAPI.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :password_hash, :string
      add :is_confirmed, :boolean, default: false, null: false
      add :source, :string
      add :confirmation_token, :string
      add :restore_token, :string
      add :is_removed, :boolean, default: false, null: false
      add :removed_at, :naive_datetime
      add :failed_sign_in_attempts, :integer
      add :failed_restore_attempts, :integer
      add :confirmed_at, :naive_datetime
      add :confirmation_sent_at, :naive_datetime
      add :restore_requested_at, :naive_datetime
      add :restore_accepted_at, :naive_datetime
      add :last_visited_at, :naive_datetime
      add :invited_at, :naive_datetime

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
