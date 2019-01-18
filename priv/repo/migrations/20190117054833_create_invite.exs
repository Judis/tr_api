defmodule I18NAPI.Repo.Migrations.CreateInvite do
  use Ecto.Migration

  def up do
    create table(:invite) do
      add :inviter_id, references(:users, on_delete: :delete_all)
      add :message, :string

      add :role, :integer
      add :recipient_id, references(:users, on_delete: :delete_all)
      add :project_id, references(:projects, on_delete: :delete_all)

      add :token, :string
      add :invited_at, :naive_datetime
      add :accepted_at, :naive_datetime

      add :is_removed, :boolean, default: false
      add :removed_at, :naive_datetime

      timestamps()
    end

    alter table(:users) do
      remove :invited_at
    end
  end

  def down do
    drop_if_exists table(:invite)
    alter table(:users) do
      add :invited_at, :naive_datetime
    end
  end
end
