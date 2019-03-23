defmodule I18NAPI.Projects.Invite do
  use Ecto.Schema
  import Ecto.Changeset
  alias I18NAPI.Utilities

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
    |> validate_required([:inviter_id, :message, :recipient_id, :project_id, :role])
  end

  @doc false
  def update_changeset(invite, attrs) do
    invite
    |> cast(attrs, [:message, :recipient_id, :project_id, :role])
    |> validate_required([:inviter_id, :message, :recipient_id, :project_id, :role])
  end

  @doc false
  def accept_changeset(invite) do
    invite
    |> cast(%{accepted_at: NaiveDateTime.utc_now(), token: nil}, [:accepted_at, :token])
  end

  @doc false
  def invite_changeset(invite) do
    invite
    |> cast(%{invited_at: NaiveDateTime.utc_now()}, [:invited_at])
  end

  @doc false
  def remove_changeset(invite) do
    invite
    |> cast(%{is_removed: true, removed_at: Utilities.get_utc_now()}, [:is_removed, :removed_at])
    |> validate_required([:is_removed, :removed_at])
  end
end
