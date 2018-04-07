defmodule I18NAPI.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :confirmation_sent_at, :naive_datetime
    field :confirmation_token, :string
    field :confirmed_at, :naive_datetime
    field :email, :string
    field :failed_restore_attempts, :integer
    field :failed_sign_in_attempts, :integer
    field :invited_at, :naive_datetime
    field :is_confirmed, :boolean, default: false
    field :last_visited_at, :naive_datetime
    field :name, :string
    field :password_hash, :string
    field :restore_accepted_at, :naive_datetime
    field :restore_requested_at, :naive_datetime
    field :restore_token, :string
    field :source, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password_hash, :is_confirmed, :source, :confirmation_token, :restore_token, :failed_sign_in_attempts, :failed_restore_attempts, :confirmed_at, :confirmation_sent_at, :restore_requested_at, :restore_accepted_at, :last_visited_at, :invited_at])
    |> validate_required([:name, :email, :password_hash, :is_confirmed, :source, :confirmation_token, :restore_token, :failed_sign_in_attempts, :failed_restore_attempts, :confirmed_at, :confirmation_sent_at, :restore_requested_at, :restore_accepted_at, :last_visited_at, :invited_at])
    |> unique_constraint(:email)
  end
end
