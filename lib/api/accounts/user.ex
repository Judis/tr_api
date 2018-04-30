defmodule I18NAPI.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:confirmation_sent_at, :naive_datetime)
    field(:confirmation_token, :string)
    field(:confirmed_at, :naive_datetime)
    field(:email, :string)
    field(:failed_restore_attempts, :integer)
    field(:failed_sign_in_attempts, :integer)
    field(:invited_at, :naive_datetime)
    field(:is_confirmed, :boolean, default: false)
    field(:last_visited_at, :naive_datetime)
    field(:name, :string)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)
    field(:password_hash, :string)
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
      :source
    ])
    |> validate_required([:name, :email, :password, :password_confirmation])
    |> validate_changeset
  end

  @doc false
  defp validate_changeset(struct) do
    struct
    |> validate_length(:email, min: 5, max: 255)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
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
  defp generate_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(password))

      _ ->
        changeset
    end
  end
end
