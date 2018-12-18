defmodule I18NAPI.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias I18NAPI.Repo
  alias I18NAPI.Utilites
  alias I18NAPI.UserEmail
  alias I18NAPI.Accounts.User
  alias I18NAPI.Accounts.Confirmation

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
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
    |> Confirmation.send_confirmation_email_async
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
      nil  -> {:error, :unauthorized}
      user -> {:ok, user}
    end
  end

  def add_confirmation_token_to_user(%User{} = user, confirmation_token) do
    attrs = %{
      confirmation_token: confirmation_token,
      confirmation_sent_at: NaiveDateTime.utc_now
    }
    user
    |> User.confirmation_changeset(attrs)
    |> Repo.update()
  end

  def confirm_user(%User{} = user) do
    attrs = %{
      confirmation_token: nil,
      confirmation_sent_at: nil,
      confirmed_at: NaiveDateTime.utc_now,
      is_confirmed: true
    }
    user
    |> User.confirmation_changeset(attrs)
    |> Repo.update()
  end
end
