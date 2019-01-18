defmodule I18NAPI.Projects.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invite" do
    belongs_to(:inviter, I18NAPI.Accounts.User)
    field(:message, :string)

    belongs_to(:recipient, I18NAPI.Accounts.User)
    belongs_to(:project, I18NAPI.Projects.Project)
    field(:role, RoleEnum)

    field(:token, :string)
    field(:invited_at, :naive_datetime)
    field(:accepted_at, :naive_datetime)

    field(:is_removed, :boolean, default: false)
    field(:removed_at, :naive_datetime)

    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:inviter_id, :message, :recipient_id, :project_id, :role, :token])
    |> validate_required([:inviter_id, :message, :recipient_id, :project_id, :role, :token])
  end

  @doc false
  def remove_changeset(invite, attrs) do
    invite
    |> cast(attrs, [:is_removed, :removed_at])
    |> validate_required([:is_removed, :removed_at])
  end
end
