defmodule I18NAPI.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias I18NAPI.Repo

  alias I18NAPI.Projects.Project
  alias I18NAPI.Translations
  alias I18NAPI.Translations.Locale
  alias I18NAPI.Utilities

  def default_locale_to_project(%Project{} = project) do
    locale = Translations.get_default_locale!(project.id)
    %{project | default_locale: locale.locale}
  end

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all(Project)
    |> Enum.map(fn p -> default_locale_to_project(p) end)
  end

  @doc """
  Returns the list of projects chained with specific user.

  ## Examples

      iex> list_projects(1)
      [%Project{}, ...]

  """
  def list_projects(user_id) do
    from(
      p in Project,
      join: ur in "user_roles",
      on: p.id == ur.project_id,
      where: ur.user_id == ^user_id and p.is_removed == false,
      order_by: p.name
    )
    |> Repo.all()
    |> Enum.map(fn p -> default_locale_to_project(p) end)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id) |> default_locale_to_project()

  @doc """
  Gets a single project.

  Return :nil if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      nil

  """
  def get_project(id), do: Repo.get(Project, id) |> default_locale_to_project()

  def get_total_count_of_translation_keys(project_id) do
    from(
      p in Project,
      where: [id: ^project_id],
      select: p.total_count_of_translation_keys
    )
    |> Repo.one!()
  end

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}, user) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
    |> create_owner_for_project(user)
    |> create_default_locale_for_project(user)
  end

  @doc """
  Creates a owner for project.

  ## Examples

      iex> create_owner_for_project({:ok, %Project{}}, %User{})
      {:ok, %Project{}}

  """
  def create_owner_for_project({:ok, %Project{} = project}, %{} = user) do
    create_user_roles(%{
      project_id: project.id,
      user_id: user.id,
      role: 1
    })

    {:ok, project}
  end

  def create_owner_for_project(_ = response, %{} = user) do
    response
  end

  @doc """
  Creates a default locale for project.

  ## Examples

      iex> create_default_locale_for_project({:ok, %Project{}})
      {:ok, %Project{}}

  """
  def create_default_locale_for_project({:ok, %Project{} = project}, owner) do
    I18NAPI.Translations.create_locale(
      %{
        "locale" => project.default_locale,
        "is_default" => true
      },
      project.id
    )
    |> create_default_locale_relation_for_owner(owner)

    {:ok, project}
  end

  def create_default_locale_for_project(response, _) do
    response
  end

  defp create_default_locale_relation_for_owner({:ok, %Locale{} = locale}, %{} = user) do
    create_user_locales(%{
      user_id: user.id,
      locale_id: locale.id,
      role: 1
    })
  end

  defp create_default_locale_relation_for_owner(_ = response, %{} = user) do
    response
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Safely Deletes a Project.

  ## Examples

      iex> safely_delete_project(project)
      {:ok, %Project{}}

      iex> safely_delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def safely_delete_project(%Project{} = project) do
    changeset = %{
      is_removed: true,
      removed_at: DateTime.utc_now()
    }

    project
    |> Project.remove_changeset(changeset)
    |> Repo.update()
    |> safely_delete_nested_entities(:locales)
    |> safely_delete_nested_entities(:translation_keys)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{source: %Project{}}

  """
  def change_project(%Project{} = project) do
    Project.changeset(project, %{})
  end

  alias I18NAPI.Projects.UserRole

  @doc """
  Returns the list of user_roles.

  ## Examples

      iex> list_user_roles()
      [%UserRole{}, ...]

  """
  def list_user_roles do
    Repo.all(UserRole)
  end

  @doc """
  Gets a single user_roles.

  Raises `Ecto.NoResultsError` if the User roles does not exist.

  ## Examples

      iex> get_user_roles!(123)
      %UserRole{}

      iex> get_user_roles!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_roles!(id), do: Repo.get!(UserRole, id)

  @doc """
  Gets a single user_roles.

  Raises `Ecto.NoResultsError` if the User roles does not exist.

  ## Examples

      iex> get_user_roles!(123, 321)
      %UserRole{}

      iex> get_user_roles!(456, 654)
      ** (Ecto.NoResultsError)

  """
  def get_user_roles!(project_id, user_id) do
    from(
      ur in UserRole,
      where: ur.project_id == ^project_id and ur.user_id == ^user_id
    )
    |> Repo.one()
  end

  @doc """
  Creates a user_roles.

  ## Examples

      iex> create_user_roles(%{field: value})
      {:ok, %UserRole{}}

      iex> create_user_roles(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_roles(attrs \\ %{}) do
    %UserRole{}
    |> UserRole.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_roles.

  ## Examples

      iex> update_user_roles(user_roles, %{field: new_value})
      {:ok, %UserRole{}}

      iex> update_user_roles(user_roles, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_roles(%UserRole{} = user_roles, attrs) do
    user_roles
    |> UserRole.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a UserRole.

  ## Examples

      iex> delete_user_roles(user_roles)
      {:ok, %UserRole{}}

      iex> delete_user_roles(user_roles)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_roles(%UserRole{} = user_roles) do
    Repo.delete(user_roles)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_roles changes.

  ## Examples

      iex> change_user_roles(user_roles)
      %Ecto.Changeset{source: %UserRole{}}

  """
  def change_user_roles(%UserRole{} = user_roles) do
    UserRole.changeset(user_roles, %{})
  end

  alias I18NAPI.Projects.UserLocales

  @doc """
  Returns the list of user_locales.

  ## Examples

      iex> list_user_locales()
      [%UserLocales{}, ...]

  """
  def list_user_locales do
    Repo.all(UserLocales)
  end

  @doc """
  Gets a single user_locales.

  Raises `Ecto.NoResultsError` if the User locales does not exist.

  ## Examples

      iex> get_user_locales!(123)
      %UserLocales{}

      iex> get_user_locales!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_locales!(id), do: Repo.get!(UserLocales, id)

  @doc """
  Gets a single user_locales.

  Raises `Ecto.NoResultsError` if the User locales does not exist.

  ## Examples

      iex> get_user_locales!(123, 321)
      %UserLocales{}

      iex> get_user_locales!(456, 654)
      ** (Ecto.NoResultsError)

  """
  def get_user_locales!(locale_id, user_id) do
    from(
      ul in UserLocales,
      where: ul.locale_id == ^locale_id and ul.user_id == ^user_id
    )
    |> Repo.one()
  end

  @doc """
  Creates a user_locales.

  ## Examples

      iex> create_user_locales(%{field: value})
      {:ok, %UserLocales{}}

      iex> create_user_locales(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_locales(attrs \\ %{}) do
    %UserLocales{}
    |> UserLocales.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_locales.

  ## Examples

      iex> update_user_locales(user_locales, %{field: new_value})
      {:ok, %UserLocales{}}

      iex> update_user_locales(user_locales, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_locales(%UserLocales{} = user_locales, attrs) do
    user_locales
    |> UserLocales.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a UserLocales.

  ## Examples

      iex> delete_user_locales(user_locales)
      {:ok, %UserLocales{}}

      iex> delete_user_locales(user_locales)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_locales(%UserLocales{} = user_locales) do
    Repo.delete(user_locales)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_locales changes.

  ## Examples

      iex> change_user_locales(user_locales)
      %Ecto.Changeset{source: %UserLocales{}}

  """
  def change_user_locales(%UserLocales{} = user_locales) do
    UserLocales.update_changeset(user_locales, %{})
  end

  @doc """
  Safely Deletes nested Entities

  ## Examples

      iex> safely_delete_nested_entities({:ok, %TranslationKey{}})
      {:ok, %TranslationKey{}}
  """
  def safely_delete_nested_entities({:ok, %{} = parent}, children_key) do
    parent
    |> Repo.preload(children_key)
    |> Map.fetch!(children_key)
    |> Enum.each(fn children ->
      safely_delete_entity(children)
    end)

    {:ok, parent}
  end

  def safely_delete_entity(%I18NAPI.Translations.TranslationKey{} = child) do
    I18NAPI.Translations.safely_delete_translation_key(child)
  end

  def safely_delete_entity(%I18NAPI.Translations.Locale{} = child) do
    I18NAPI.Translations.safely_delete_locale(child)
  end

  alias I18NAPI.Projects.Invite

  @doc """
  Returns the list of invites chained with specific inviter.

  ## Examples

      iex> list_invites_by_inviter(1)
      [%Invite{}, ...]

  """
  def list_invites_by_inviter(inviter_id) do
    from(
      i in Invite,
      where: [inviter_id: ^inviter_id, is_removed: false]
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of invites chained with specific project.

  ## Examples

      iex> list_invites_by_project(1)
      [%Invite{}, ...]

  """
  def list_invites_by_project(project_id) do
    from(
      i in Invite,
      where: [project_id: ^project_id, is_removed: false]
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of invites chained with specific recipient.

  ## Examples

      iex> list_invites_by_recipient(1)
      [%Invite{}, ...]

  """
  def list_invites_by_recipient(recipient_id) do
    from(
      i in Invite,
      where: [recipient_id: ^recipient_id, is_removed: false]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single invite.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_invite!(123)
      %Invite{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invite!(id), do: Repo.get!(Invite, id)

  @doc """
  Gets a single invite.

  Return :nil if the Invite does not exist.

  ## Examples

      iex> get_invite!(123)
      %Project{}

      iex> get_invite!(456)
      nil

  """
  def get_invite(id), do: Repo.get(Invite, id)

  @doc """
  Find invite by token.

  ## Examples

      iex> find_invite_by_token(token)
      {:ok, %Invite{}}

      iex> find_invite_by_token(token)
      {:error, :unauthorized}

  """
  def find_invite_by_token(token) do
    case Repo.get_by(Invite, token: token) do
      nil -> {:error, :unauthorized}
      invite -> {:ok, invite}
    end
  end

  @doc """
  Accepts a invite.

  ## Examples

      iex> accept_invite(%Invite{} = invite)
      {:ok, %Invite{}}

      iex> accept_invite(%{bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def accept_invite(%Invite{} = invite) do
    invite
    |> Invite.accept_changeset()
    |> Repo.update()
  end

  def accept_invite(_), do: {:error, :bad_value}

  @doc """
  Creates a invite.

  ## Examples

      iex> create_invite(%{field: value})
      {:ok, %Invite{}}

      iex> create_invite(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invite(attrs \\ %{}) do
    %Invite{}
    |> Invite.changeset(
      attrs
      |> Map.put(:token, Utilities.random_string(32))
      |> Map.put(:invited_at, NaiveDateTime.utc_now())
      |> Utilities.key_to_atom()
    )
    |> Repo.insert()
  end

  @doc """
  Updates a invite.

  ## Examples

      iex> update_invite(invite, %{field: new_value})
      {:ok, %Invite{}}

      iex> update_invite(invite, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invite(%Invite{} = invite, attrs) do
    invite
    |> Invite.changeset(attrs)
    |> Repo.update()
  end

  def update_field_invited_at(%Invite{} = invite) do
    invite
    |> Invite.invite_changeset()
    |> Repo.update()
  end

  @doc """
  Deletes a Invite.

  ## Examples

      iex> delete_invite(invite)
      {:ok, %Project{}}

      iex> delete_invite(invite)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invite(%Invite{} = invite) do
    Repo.delete(invite)
  end

  @doc """
  Safely Deletes a Invite.

  ## Examples

      iex> safely_delete_invite(invite)
      {:ok, %Invite{}}

      iex> safely_delete_invite(invite)
      {:error, %Ecto.Changeset{}}

  """
  def safely_delete_invite(%Invite{} = invite) do
    changeset = %{
      is_removed: true,
      removed_at: DateTime.utc_now()
    }

    invite
    |> Invite.remove_changeset(changeset)
    |> Repo.update()
  end
end
