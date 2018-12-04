defmodule I18NAPI.Translations do
  @moduledoc """
  The Translations context.
  """

  import Ecto.Query, warn: false
  alias I18NAPI.Repo
  alias I18NAPI.Utilites
  alias I18NAPI.Translations.Locale
  alias I18NAPI.Translations.Translation
  alias I18NAPI.Projects

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
        where: pr.id == ^project_id and p.is_removed == false
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
  Returns the list of locales chained with specific project.

  ## Examples

      iex> list_locales(1)
      %Locale{}

  """
  def get_default_locale!(project_id) do
    query =
      from(
        p in Locale,
        where: p.project_id == ^project_id and p.is_default == true
      )

    Repo.one!(query)
  end

  @doc """
  Creates a locale.

  ## Examples

      iex> create_locale(%{field: value})
      {:ok, %Locale{}}

      iex> create_locale(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_locale(attrs, project_id) do
    attrs = Utilites.key_to_string(attrs)
    attrs = Map.put(attrs, "project_id", project_id)
    attrs = Map.put(attrs, "count_of_untranslated_keys", Projects.get_total_count_of_translation_keys(project_id))
    %Locale{}
    |> Locale.changeset(attrs)
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
    list_translation_keys = Repo.all(TranslationKey)
    Enum.map list_translation_keys, fn(translation_key) ->
      default_value = get_default_translation_value(translation_key.id)
      Map.put(translation_key, :default_value, default_value)
    end
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

    list_translation_keys = Repo.all(query)

    Enum.map list_translation_keys, fn(translation_key) ->
      default_value = get_default_translation_value(translation_key.id)
      Map.put(translation_key, :default_value, default_value)
    end
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
  def get_translation_key!(id) do
    translation_key = Repo.get!(TranslationKey, id)
    default_value = get_default_translation_value(translation_key.id)
    Map.put(translation_key, :default_value, default_value)
  end

  @doc """
  Creates a translation_key.

  ## Examples

      iex> create_translation_key(%{field: value})
      {:ok, %TranslationKey{}}

      iex> create_translation_key(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_translation_key(attrs \\ %{}, project_id) do
    attrs = Utilites.key_to_string(attrs)
    changeset = Map.put(attrs, "project_id", project_id) |> Utilites.key_to_atom()
    %TranslationKey{}
    |> TranslationKey.changeset(changeset)
    |> Repo.insert()
    |> create_default_translation()
  end

  @doc """
  Creates a default translation for translation_key.

  ## Examples

      iex> create_default_translation({:ok, %TranslationKey{}})
      {:ok, %TranslationKey{}}

  """
  def create_default_translation({:ok, %TranslationKey{} = translation_key}) do
    default_locale = get_default_locale!(translation_key.project_id)
    translation = create_translation(
      %{
        "translation_key_id" => translation_key.id,
        "value" => translation_key.default_value,
        "status" => :unverified
      },
      default_locale.id
    )
    {:ok, translation_key}
  end

  def create_default_translation(_ = response) do
    response
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
    responce = translation_key
    |> TranslationKey.changeset(attrs)
    |> Repo.update()

    with {:ok, translation_key} <- responce do
      get_default_translation(translation_key.id)
      |> Translation.changeset(%{value: attrs.default_value})
      |> Repo.update()

      {:ok, Map.put(translation_key, :default_value, attrs.default_value)}
    end
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
    response = translation_key
    |> TranslationKey.changeset(%{is_removed: true})
    |> Repo.update()

    with {:ok, translation_key} <- response do
      Statistics.update_total_count_of_translation_keys(translation_key.project_id, :dec)
      Statistics.recalculate_count_of_untranslated_keys_at_locales(translation_key.project_id)
    end

    response
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

    response = translation_key
    |> TranslationKey.remove_changeset(chaneset)
    |> Repo.update()
    |> safely_delete_nested_entities(:translations)

    with {:ok, translation_key} <- response do
      Statistics.update_total_count_of_translation_keys(translation_key.project_id, :dec)
      Statistics.recalculate_count_of_untranslated_keys_at_locales(translation_key.project_id)
    end

    response
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
  def create_translation(attrs \\ %{status: :empty, is_removed: false}, locale_id) do
    changeset = Map.put(attrs, :locale_id, locale_id) |> Utilites.key_to_atom()
    response = %Translation{}
    |> Translation.changeset(changeset)
    |> Repo.insert()

    with {:ok, translation} <- response,
         true <- Map.has_key?(changeset, :status),
         do: Statistics.update_count_choice(translation.locale_id, :empty, changeset.status)

    response
  end

  @doc """
  Updates a translation.

  ## Examples

      iex> update_translation(translation, %{field: new_value})
      {:ok, %Translation{}}

      iex> update_translation(translation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_translation(%Translation{} = translation, attrs \\%{}) do
    pattern = ["status", "value", :status, :value]
    attrs = Map.take(attrs, pattern) |> Utilites.key_to_atom()

    result = translation
    |> Translation.changeset(attrs)
    |> Repo.update()

    with {:ok, translation} <- result,
         true <- Map.has_key?(attrs, :status),
         do: Statistics.update_count_choice(translation.locale_id, translation.status, attrs.status)

    with true <- is_default_locale?(translation.locale_id),
         true <- Map.has_key?(attrs, :value),
         true <- translation.value != attrs.value,
         do: change_status_for_all_translation_key(translation.translation_key_id)

    result
  end

  defp is_default_locale?(locale_id) do
      from(
        locl in Locale,
        select: locl.is_default,
        where: locl.id == ^locale_id
      )
      |> Repo.one!()
  end

  defp change_status_for_all_translation_key(translation_key_id) do
    from(
      tr in Translation,
      join: lcl in Locale,
      on: lcl.id == tr.locale_id,
      where: (tr.translation_key_id == ^translation_key_id) and not (lcl.is_default)
    )
    |> Repo.update_all(set: [status: "need_check"])
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

  @doc """
  Get all translation_keys and translations for locale

  ## Example

      iex> get_keys_and_translations(locale)
      {:ok, %TranslationKey{}}
  """
  def get_keys_and_translations(locale) do
    default_locale = get_default_locale!(locale.project_id)
    translation_keys = list_translation_keys(default_locale.project_id)
    default_transaltions = list_translations(default_locale.id)
    current_transaltions = list_translations(locale.id)

    Enum.map(translation_keys, fn key ->
      %{
        translation_key_id: key.id,
        key: key.key,
        context: key.context,
        default_value: get_translation_value(default_transaltions, key.id),
        current_value: get_translation_value(current_transaltions, key.id)
      }
    end)
  end

  defp get_translation_value(translations, key_id) do
    translation =
      List.first(Enum.filter(translations, fn x -> x.translation_key_id == key_id end))

    if translation do
      %{id: translation.id, value: translation.value}
    else
      nil
    end
  end

  def get_default_translation(key_id) do
    query =
      from(
        tr in Translation,
        join: locl in Locale,
        on: [id: tr.locale_id],
        where: tr.translation_key_id == ^key_id and locl.is_default == true
      )
      Repo.one(query)
  end

  def get_default_translation_value(key_id) do
    query =
      from(
        tr in Translation,
        join: locl in Locale,
        on: [id: tr.locale_id],
        select: tr.value,
        where: tr.translation_key_id == ^key_id and locl.is_default == true
      )
      Repo.one(query)
  end
end
