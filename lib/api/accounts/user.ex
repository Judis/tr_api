defmodule I18NAPI.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias I18NAPI.Accounts.User

  schema "users" do
    field(:confirmation_sent_at, :naive_datetime)
    field(:confirmation_token, :string)
    field(:confirmed_at, :naive_datetime)
    field(:email, :string)
    field(:failed_restore_attempts, :integer)
    field(:failed_sign_in_attempts, :integer)
    field(:invited_at, :naive_datetime)
    field(:is_confirmed, :boolean, default: false)
    field(:is_removed, :boolean, default: false)
    field(:last_visited_at, :naive_datetime)
    field(:name, :string)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)
    field(:password_hash, :string)
    field(:removed_at, :naive_datetime)
    field(:restore_accepted_at, :naive_datetime)
    field(:restore_requested_at, :naive_datetime)
    field(:restore_token, :string)
    field(:source, :string)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :name,
      :email,
      :password,
      :password_confirmation,
      :source,
      :confirmation_token
    ])
    |> validate_required([:name, :email, :password, :password_confirmation])
    |> validate_changeset
  end

  @doc false
  defp validate_changeset(struct) do
    struct
    |> validate_email
    |> validate_password
  end

  @doc false
  defp validate_email(struct) do
    struct
    |> validate_length(:email, min: 5, max: 255)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  @doc false
  defp validate_password(struct) do
    struct
    |> validate_length(:password, min: 8)
    |> validate_format(
      :password,
      ~r/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).*/,
      message: "Must include at least one lowercase letter, one uppercase letter, and one digit"
    )
    |> validate_confirmation(:password)
    |> generate_password_hash
  end

  @doc false
  def confirmation_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :confirmation_token,
      :confirmation_sent_at,
      :confirmed_at,
      :is_confirmed
    ])
  end

  @doc false
  def invite_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :invited_at
    ])
  end

  @doc false
  def accept_invite_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :invited_at,
      :confirmation_token,
      :confirmation_sent_at,
      :confirmed_at,
      :is_confirmed,
      :restore_accepted_at,
      :restore_token,
      :password,
      :password_confirmation
    ])
    |> validate_required([:confirmed_at, :restore_accepted_at, :password, :password_confirmation])
    |> validate_password
  end

  @doc false
  def restore_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :invited_at,
      :restore_token,
      :restore_accepted_at,
      :restore_requested_at,
      :password,
      :password_confirmation
    ])
    |> validate_required([:restore_token, :password, :password_confirmation])
    |> validate_password
  end

  @doc false
  def remove_changeset(user, attrs) do
    user
    |> cast(attrs, [:is_removed, :removed_at])
    |> validate_required([:is_removed, :removed_at])
  end

  @doc false
  defp generate_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(password))

      _ ->
        changeset
    end
  end

  @doc false
  def validate_string_password(password) do
    result = %User{}
             |> cast(%{password: password}, [:password])
             |> validate_required([:password])
             |> validate_password

    if [] == result.errors do
      password
    else
      {:error}
    end
  end
end
