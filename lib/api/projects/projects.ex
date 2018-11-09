defmodule I18NAPI.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias I18NAPI.Repo

  alias I18NAPI.Projects.Project
  alias I18NAPI.Translations
  alias I18NAPI.Translations.Locale

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
    query =
      from(
        p in Project,
        join: ur in "user_roles",
        on: p.id == ur.project_id,
        where: ur.user_id == ^user_id and p.is_removed == false,
        order_by: p.name
      )

    Repo.all(query)
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
    |> create_default_locale_for_project()
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
  def create_default_locale_for_project({:ok, %Project{} = project}) do
    I18NAPI.Translations.create_locale(
      %{
        "locale" => project.default_locale,
        "is_default" => true
      },
      project.id
    )

    {:ok, project}
  end

  def create_default_locale_for_project(_ = response) do
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
    chaneset = %{
      is_removed: true,
      removed_at: DateTime.utc_now()
    }

    project
    |> Project.remove_changeset(chaneset)
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

  alias I18NAPI.Projects.UserRoles

  @doc """
  Returns the list of user_roles.

  ## Examples

      iex> list_user_roles()
      [%UserRoles{}, ...]

  """
  def list_user_roles do
    Repo.all(UserRoles)
  end

  @doc """
  Gets a single user_roles.

  Raises `Ecto.NoResultsError` if the User roles does not exist.

  ## Examples

      iex> get_user_roles!(123)
      %UserRoles{}

      iex> get_user_roles!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_roles!(id), do: Repo.get!(UserRoles, id)

  @doc """
  Creates a user_roles.

  ## Examples

      iex> create_user_roles(%{field: value})
      {:ok, %UserRoles{}}

      iex> create_user_roles(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_roles(attrs \\ %{}) do
    %UserRoles{}
    |> UserRoles.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_roles.

  ## Examples

      iex> update_user_roles(user_roles, %{field: new_value})
      {:ok, %UserRoles{}}

      iex> update_user_roles(user_roles, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_roles(%UserRoles{} = user_roles, attrs) do
    user_roles
    |> UserRoles.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a UserRoles.

  ## Examples

      iex> delete_user_roles(user_roles)
      {:ok, %UserRoles{}}

      iex> delete_user_roles(user_roles)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_roles(%UserRoles{} = user_roles) do
    Repo.delete(user_roles)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_roles changes.

  ## Examples

      iex> change_user_roles(user_roles)
      %Ecto.Changeset{source: %UserRoles{}}

  """
  def change_user_roles(%UserRoles{} = user_roles) do
    UserRoles.changeset(user_roles, %{})
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
  Creates a user_locales.

  ## Examples

      iex> create_user_locales(%{field: value})
      {:ok, %UserLocales{}}

      iex> create_user_locales(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_locales(attrs \\ %{}) do
    %UserLocales{}
    |> UserLocales.changeset(attrs)
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
    |> UserLocales.changeset(attrs)
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
    UserLocales.changeset(user_locales, %{})
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

  def safely_delete_entity(%I18NAPI.Translations.TranslationKey{} = child),
    do: I18NAPI.Translations.safely_delete_translation_key(child)

  def safely_delete_entity(%I18NAPI.Translations.Locale{} = child),
    do: I18NAPI.Translations.safely_delete_locale(child)
end
