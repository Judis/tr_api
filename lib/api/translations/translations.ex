defmodule I18NAPI.Translations do
  @moduledoc """
  The Translations context.
  """

  import Ecto.Query, warn: false
  alias I18NAPI.Repo

  alias I18NAPI.Translations.Locale

  @doc """
  Returns the list of locales.

  ## Examples

      iex> list_locales()
      [%Locale{}, ...]

  """
  def list_locales do
    Repo.all(Locale)
  end

  @doc """
  Returns the list of locales chained with specific project.

  ## Examples

      iex> list_locales(1)
      [%Locale{}, ...]

  """
  def list_locales(project_id) do
    query =
      from(
        p in Locale,
        join: pr in I18NAPI.Projects.Project,
        on: p.project_id == pr.id,
        where: pr.id == ^project_id
      )

    Repo.all(query)
  end

  @doc """
  Gets a single locale.

  Raises `Ecto.NoResultsError` if the Locale does not exist.

  ## Examples

      iex> get_locale!(123)
      %Locale{}

      iex> get_locale!(456)
      ** (Ecto.NoResultsError)

  """
  def get_locale!(id), do: Repo.get!(Locale, id)

  @doc """
  Creates a locale.

  ## Examples

      iex> create_locale(%{field: value})
      {:ok, %Locale{}}

      iex> create_locale(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_locale(attrs \\ %{}, project_id) do
    changeset = Map.put(attrs, "project_id", project_id)

    %Locale{}
    |> Locale.changeset(changeset)
    |> Repo.insert()
  end

  @doc """
  Updates a locale.

  ## Examples

      iex> update_locale(locale, %{field: new_value})
      {:ok, %Locale{}}

      iex> update_locale(locale, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_locale(%Locale{} = locale, attrs) do
    locale
    |> Locale.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Locale.

  ## Examples

      iex> delete_locale(locale)
      {:ok, %Locale{}}

      iex> delete_locale(locale)
      {:error, %Ecto.Changeset{}}

  """
  def delete_locale(%Locale{} = locale) do
    Repo.delete(locale)
  end

  @doc """
  Safely Deletes a Locale.

  ## Examples

      iex> safely_delete_locale(locale)
      {:ok, %Locale{}}

      iex> safely_delete_locale(locale)
      {:error, %Ecto.Changeset{}}

  """
  def safely_delete_locale(%Locale{} = locale) do
    chaneset = %{
      is_removed: true,
      removed_at: DateTime.utc_now()
    }

    locale
    |> Locale.remove_changeset(chaneset)
    |> Repo.update()
    |> safely_delete_nested_entities(:translations)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking locale changes.

  ## Examples

      iex> change_locale(locale)
      %Ecto.Changeset{source: %Locale{}}

  """
  def change_locale(%Locale{} = locale) do
    Locale.changeset(locale, %{})
  end

  alias I18NAPI.Translations.TranslationKey

  @doc """
  Returns the list of translation_keys.

  ## Examples

      iex> list_translation_keys()
      [%TranslationKey{}, ...]

  """
  def list_translation_keys do
    Repo.all(TranslationKey)
  end

  @doc """
  Returns the list of translation keys chained with specific project.

  ## Examples

      iex> list_translation_keys(1)
      [%TranslationKey{}, ...]

  """
  def list_translation_keys(project_id) do
    query =
      from(
        p in TranslationKey,
        join: pr in I18NAPI.Projects.Project,
        on: p.project_id == pr.id,
        where: pr.id == ^project_id
      )

    Repo.all(query)
  end

  @doc """
  Gets a single translation_key.

  Raises `Ecto.NoResultsError` if the Translation key does not exist.

  ## Examples

      iex> get_translation_key!(123)
      %TranslationKey{}

      iex> get_translation_key!(456)
      ** (Ecto.NoResultsError)

  """
  def get_translation_key!(id), do: Repo.get!(TranslationKey, id)

  @doc """
  Creates a translation_key.

  ## Examples

      iex> create_translation_key(%{field: value})
      {:ok, %TranslationKey{}}

      iex> create_translation_key(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_translation_key(attrs \\ %{}, project_id) do
    changeset = Map.put(attrs, "project_id", project_id)

    %TranslationKey{}
    |> TranslationKey.changeset(changeset)
    |> Repo.insert()
  end

  @doc """
  Updates a translation_key.

  ## Examples

      iex> update_translation_key(translation_key, %{field: new_value})
      {:ok, %TranslationKey{}}

      iex> update_translation_key(translation_key, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_translation_key(%TranslationKey{} = translation_key, attrs) do
    translation_key
    |> TranslationKey.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TranslationKey.

  ## Examples

      iex> delete_translation_key(translation_key)
      {:ok, %TranslationKey{}}

      iex> delete_translation_key(translation_key)
      {:error, %Ecto.Changeset{}}

  """
  def delete_translation_key(%TranslationKey{} = translation_key) do
    Repo.delete(translation_key)
  end

  @doc """
  Safely Deletes a TranslationKey.

  ## Examples

      iex> safely_delete_translation_key(translation_key)
      {:ok, %TranslationKey{}}

      iex> safely_delete_translation_key(translation_key)
      {:error, %Ecto.Changeset{}}

  """
  def safely_delete_translation_key(%TranslationKey{} = translation_key) do
    chaneset = %{
      is_removed: true,
      removed_at: DateTime.utc_now()
    }

    translation_key
    |> TranslationKey.remove_changeset(chaneset)
    |> Repo.update()
    |> safely_delete_nested_entities(:translations)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking translation_key changes.

  ## Examples

      iex> change_translation_key(translation_key)
      %Ecto.Changeset{source: %TranslationKey{}}

  """
  def change_translation_key(%TranslationKey{} = translation_key) do
    TranslationKey.changeset(translation_key, %{})
  end

  alias I18NAPI.Translations.Translation

  @doc """
  Returns the list of translations.

  ## Examples

      iex> list_translations()
      [%Translation{}, ...]

  """
  def list_translations do
    Repo.all(Translation)
  end

  @doc """
  Returns the list of translations associated with specific locale

  ## Examples

      iex> list_translations(1)
      [%Translation{}, ...]

  """
  def list_translations(locale_id) do
    query =
      from(
        p in Translation,
        join: pr in I18NAPI.Translations.Locale,
        on: p.locale_id == pr.id,
        where: pr.id == ^locale_id
      )

    Repo.all(query)
  end

  @doc """
  Gets a single translation.

  Raises `Ecto.NoResultsError` if the Translation does not exist.

  ## Examples

      iex> get_translation!(123)
      %Translation{}

      iex> get_translation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_translation!(id), do: Repo.get!(Translation, id)

  @doc """
  Creates a translation.

  ## Examples

      iex> create_translation(%{field: value}, 1)
      {:ok, %Translation{}}

      iex> create_translation(%{field: bad_value}, 1)
      {:error, %Ecto.Changeset{}}

  """
  def create_translation(attrs \\ %{}, locale_id) do
    changeset = Map.put(attrs, "locale_id", locale_id)

    %Translation{}
    |> Translation.changeset(changeset)
    |> Repo.insert()
  end

  @doc """
  Updates a translation.

  ## Examples

      iex> update_translation(translation, %{field: new_value})
      {:ok, %Translation{}}

      iex> update_translation(translation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_translation(%Translation{} = translation, attrs) do
    translation
    |> Translation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Translation.

  ## Examples

      iex> delete_translation(translation)
      {:ok, %Translation{}}

      iex> delete_translation(translation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_translation(%Translation{} = translation) do
    Repo.delete(translation)
  end

  @doc """
  Safely Deletes a Translation.

  ## Examples

      iex> safely_delete_translation(translation)
      {:ok, %Translation{}}

      iex> safely_delete_translation(translation)
      {:error, %Ecto.Changeset{}}

  """
  def safely_delete_translation(%Translation{} = translation) do
    chaneset = %{
      is_removed: true,
      removed_at: DateTime.utc_now()
    }

    translation
    |> Translation.remove_changeset(chaneset)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking translation changes.

  ## Examples

      iex> change_translation(translation)
      %Ecto.Changeset{source: %Translation{}}

  """
  def change_translation(%Translation{} = translation) do
    Translation.changeset(translation, %{})
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

  def safely_delete_entity(%Translation{} = child), do: safely_delete_translation(child)
end
