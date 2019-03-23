defmodule I18NAPI.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias I18NAPI.Accounts.User
  alias I18NAPI.Repo
  alias I18NAPI.Utilities

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Returns the list of users if not removed.

  ## Examples

      iex> list_users_not_removed()
      [%User{}, ...]

  """
  def list_users_not_removed do
    from(User, where: [is_removed: false]) |> Repo.all()
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user.

  Return nil if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a single user if not removed.

  Return nil if the User does not exist.

  ## Examples

      iex> get_user_not_removed(123)
      %User{}

      iex> get_user_not_removed(456)
      nil

  """
  def get_user_not_removed(id), do: from(User, where: [id: ^id, is_removed: false]) |> Repo.one()

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(
      attrs
      |> Map.put(:confirmation_token, Utilities.random_string(32))
      |> Utilities.key_to_atom()
    )
    |> Repo.insert()
  end

  @doc """
  Creates a user with temp password.
  Use it if you need create user without password (in fact with big unknown password)

  ## Examples

      iex> create_user_with_temp_password(%{field: value})
      {:ok, %User{}}

      iex> create_user_with_temp_password(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_with_temp_password(attrs \\ %{}) do
    attrs
    |> set_temp_password(Utilities.generate_valid_password())
    |> create_user()
  end

  defp set_temp_password(attrs, temp_pass) do
    Map.merge(attrs, %{password: temp_pass, password_confirmation: temp_pass})
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Safely deletes a User.

  ## Examples

      iex> safely_delete_user(user)
      {:ok, %User{}}

      iex> safely_delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def safely_delete_user(%User{} = user) do
    user
    |> User.remove_changeset()
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Find user by email and cofirm by password.

  ## Examples

      iex> find_and_confirm_user(email, password)
      {:ok, %User{}}

      iex> find_and_confirm_user(email, password)
      {:error, :unauthorized}

  """
  def find_and_confirm_user(email, password) do
    case Repo.get_by(User, email: email) do
      nil ->
        {:error, :unauthorized}

      user ->
        if Comeonin.Bcrypt.checkpw(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :unauthorized}
        end
    end
  end

  @doc """
  Find user by confirmation token.

  ## Examples

      iex> find_user_by_confirmation_token(confirmation_token)
      {:ok, %User{}}

      iex> find_user_by_confirmation_token(confirmation_token)
      {:error, :unauthorized}

  """
  def find_user_by_confirmation_token(confirmation_token) do
    case Repo.get_by(User, confirmation_token: confirmation_token) do
      nil -> {:error, :unauthorized}
      user -> {:ok, user}
    end
  end

  def update_field_confirmation_sent_at(%User{} = user) do
    user
    |> User.confirmation_changeset(%{confirmation_sent_at: NaiveDateTime.utc_now()})
    |> Repo.update()
  end

  @doc """
  Find user by restore token.

  ## Examples

      iex> find_user_by_restore_token(restore_token)
      {:ok, %User{}}

      iex> find_user_by_restore_token(restore_token)
      {:error, :unauthorized}

  """
  def find_user_by_restore_token(restore_token) do
    case Repo.get_by(User, restore_token: restore_token) do
      nil -> {:error, :unauthorized}
      user -> {:ok, user}
    end
  end

  @doc """
  Find user by email.

  ## Examples

      iex> find_user_by_email(email)
      {:ok, %User{}}

      iex> find_user_by_email(email)
      {:error, :not_founded}

  """
  def find_user_by_email(email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, :not_founded}
      user -> {:ok, user}
    end
  end

  def update_field_restore_token(%User{} = user, restore_token) do
    user
    |> User.restore_changeset(%{
      restore_token: restore_token,
      restore_requested_at: NaiveDateTime.utc_now()
    })
    |> Repo.update()
  end

  def update_field_password_restore_requested_at(%User{} = user) do
    user
    |> User.restore_changeset(%{restore_requested_at: NaiveDateTime.utc_now()})
    |> Repo.update()
  end

  def accept_invitation(%User{} = user, password, password_confirmation) do
    user
    |> User.accept_invite_changeset(%{
      password: password,
      password_confirmation: password_confirmation
    })
    |> Repo.update()
  end

  def accept_restoration(%User{} = user, password, password_confirmation) do
    user
    |> User.restore_changeset(%{
      restore_accepted_at: NaiveDateTime.utc_now(),
      password: password,
      password_confirmation: password_confirmation
    })
    |> Repo.update()
  end

  def confirm_user(%User{} = user) do
    user
    |> User.confirmation_changeset(%{
      confirmation_token: nil,
      confirmation_sent_at: nil,
      confirmed_at: NaiveDateTime.utc_now(),
      is_confirmed: true
    })
    |> Repo.update()
  end
end
