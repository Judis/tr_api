defmodule I18NAPI.Translations do
  @moduledoc """
  The Translations context.
  """

  import Ecto.Query, warn: false
  alias I18NAPI.Repo
  alias I18NAPI.Utilities
  alias I18NAPI.Translations.{Locale, Translation, StatisticsInterface, UserLocale}

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
  Returns the list of locales not removed.

  ## Examples

      iex> list_locales_not_removed()
      [%Locale{}, ...]

  """
  def list_locales_not_removed do
    from(Locale, where: [is_removed: false]) |> Repo.all()
  end

  @doc """
  Returns the list of locales chained with specific project.

  ## Examples

      iex> list_locales(1)
      [%Locale{}, ...]

  """
  def list_locales(project_id) do
    from(
      l in Locale,
      where: [project_id: ^project_id],
      where: [is_removed: false]
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of id of locales chained with specific project.

  ## Examples

      iex> list_locales(1)
      [id, ...]

  """
  def list_locale_identities(project_id) do
    from(
      l in Locale,
      where: [project_id: ^project_id],
      where: [is_removed: false],
      select: l.id
    )
    |> Repo.all()
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
  Gets a single locale by it locale and project_id.

  Return nil if the Locale does not exist.

  ## Examples

      iex> get_locale_by_name_and_project("en", 123)
      %Locale{}

      iex> get_locale_by_name_and_project("unknown", 456)
      nil

  """
  def get_locale_by_name_and_project(name, project_id) do
    from(
      Locale,
      where: [project_id: ^project_id],
      where: [locale: ^name]
    )
    |> Repo.one()
  end

  @doc """
  Gets a single locale not removed.

  Return nil if the Locale does not exist.

  ## Examples

      iex> get_locale_not_removed(123)
      %Locale{}

      iex> get_locale_not_removed(456)
      nil

  """
  def get_locale_not_removed(id),
    do: from(Locale, where: [id: ^id, is_removed: false]) |> Repo.one()

  @doc """
  Gets a single locale.

  Return nil if the Locale does not exist.

  ## Examples

      iex> get_locale(123)
      %Locale{}

      iex> get_locale(456)
      nil

  """
  def get_locale(id), do: Repo.get(Locale, id)

  @doc """
  Returns the default locale chained with specific project.

  ## Examples

      iex> get_default_locale!(1)
      %Locale{}

  """
  def get_default_locale!(project_id) do
    from(
      l in Locale,
      where: l.project_id == ^project_id and l.is_default == true
    )
    |> Repo.one!()
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
    attrs = Map.put(attrs, :project_id, project_id) |> Utilities.key_to_atom()

    %Locale{}
    |> Locale.changeset(attrs)
    |> Repo.insert()
    |> if_locale_set_to_default(false)
    |> create_translation_for_each_associated_key()
    |> StatisticsInterface.update_statistics(:locale, :create)
  end

  def create_translation_for_each_associated_key({:ok, %Locale{} = locale}) do
    list_translation_keys_id(locale.project_id)
    |> Enum.each(
      &fn &1 ->
        %{value: nil, status: :empty, translation_key_id: &1}
        |> create_translation(locale.id)
      end
    )

    {:ok, locale}
  end

  def create_translation_for_each_associated_key(result), do: result

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
    |> if_locale_set_to_default(locale.is_default)
    |> StatisticsInterface.update_statistics(:locale, :update)
  end

  def if_locale_set_to_default({:ok, %Locale{} = locale}, old_default_status)
      when old_default_status == false do
    with true <- locale.is_default do
      set_all_default_locale_exclude_one_as_non_default(locale.project_id, locale.id)
    end

    {:ok, locale}
  end

  def if_locale_set_to_default(result, _), do: result

  defp set_all_default_locale_exclude_one_as_non_default(project_id, exclude_locale_id) do
    from(
      l in Locale,
      where: l.id != ^exclude_locale_id,
      where: l.project_id == ^project_id,
      where: l.is_default == true
    )
    |> Repo.update_all(
      set: [
        is_default: false
      ]
    )
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
    |> StatisticsInterface.update_statistics(:locale, :delete, locale.id, locale.project_id)
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
    changeset = %{
      is_removed: true,
      removed_at: DateTime.utc_now()
    }

    locale
    |> Locale.remove_changeset(changeset)
    |> Repo.update()
    |> StatisticsInterface.update_statistics(:locale, :delete, locale.id, locale.project_id)
  end

  # deprecated
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
    |> Enum.map(fn translation_key ->
      default_value = get_default_translation_value(translation_key.id)
      Map.put(translation_key, :default_value, default_value)
    end)
  end

  @doc """
  Returns the list of translation keys chained with specific project.

  ## Examples

      iex> list_translation_keys(1)
      [%TranslationKey{}, ...]

  """
  def list_translation_keys(project_id) do
    from(
      tk in TranslationKey,
      join: pr in I18NAPI.Projects.Project,
      on: tk.project_id == pr.id,
      where: pr.id == ^project_id
    )
    |> Repo.all()
    |> Enum.map(fn translation_key ->
      default_value = get_default_translation_value(translation_key.id)

      Map.put(translation_key, :default_value, default_value)
      |> Utilities.key_to_atom()
    end)
  end

  @doc """
  Returns the list of translation keys chained with specific project if not removed.

  ## Examples

      iex> list_translation_keys_not_removed(1)
      [%TranslationKey{}, ...]

  """
  def list_translation_keys_not_removed(project_id) do
    from(
      tk in TranslationKey,
      join: pr in I18NAPI.Projects.Project,
      on: tk.project_id == pr.id,
      where: pr.id == ^project_id and tk.is_removed == false
    )
    |> Repo.all()
    |> Enum.map(fn translation_key ->
      default_value = get_default_translation_value(translation_key.id)

      Map.put(translation_key, :default_value, default_value)
      |> Utilities.key_to_atom()
    end)
  end

  @doc """
  Returns the list of translation keys id chained with specific project.

  ## Examples

      iex> list_translation_keys(1)
      [integer(), ...]

  """
  def list_translation_keys_id(project_id) do
    from(
      tk in TranslationKey,
      join: pr in I18NAPI.Projects.Project,
      on: tk.project_id == pr.id,
      where: pr.id == ^project_id,
      select: tk.id
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of translation keys id chained with specific project if not removed.

  ## Examples

      iex> list_translation_keys_id_not_removed(1)
      [integer(), ...]

  """
  def list_translation_keys_id_not_removed(project_id) do
    from(
      tk in TranslationKey,
      join: pr in I18NAPI.Projects.Project,
      on: tk.project_id == pr.id,
      where: pr.id == ^project_id and tk.is_removed == false,
      select: tk.id
    )
    |> Repo.all()
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
    with %TranslationKey{} = translation_key <- Repo.get!(TranslationKey, id) do
      default_value = get_default_translation_value(translation_key.id)
      Map.put(translation_key, :default_value, default_value)
    end
  end

  @doc """
  Gets a single translation_key by key.

  Function not return default_value

  Raises `Ecto.NoResultsError` if the Translation key does not exist.

  ## Examples

      iex> get_translation_key_by_key(123)
      %TranslationKey{}

      iex> get_translation_key_by_key(456)
      ** (Ecto.NoResultsError)

  """
  def get_translation_key_by_key(key, project_id) do
    from(TranslationKey,
      where: [key: ^key, project_id: ^project_id, is_removed: false]
    )
    |> Repo.one()
  end

  @doc """
  Gets a single translation_key if not removed.

  Return nil if the Translation key does not exist.

  ## Examples

      iex> get_translation_key_not_removed!(123)
      %TranslationKey{}

      iex> get_translation_key_not_removed!(456)
      nil

  """
  def get_translation_key_not_removed(id) do
    with %TranslationKey{} = translation_key <-
           from(TranslationKey, where: [id: ^id, is_removed: false]) |> Repo.one() do
      default_value = get_default_translation_value(translation_key.id)
      Map.put(translation_key, :default_value, default_value)
    end
  end

  @doc """
  Creates a translation_key.

  ## Examples

      iex> create_translation_key(%{field: value})
      {:ok, %TranslationKey{}}

      iex> create_translation_key(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_translation_key(attrs) do
    %TranslationKey{}
    |> TranslationKey.changeset(attrs)
    |> Repo.insert()
    |> create_default_translation()
    |> StatisticsInterface.update_statistics(:translation_key, :create)
  end

  @doc """
  Creates a translation_key.

  ## Examples

      iex> create_translation_key(%{field: value}, project_id)
      {:ok, %TranslationKey{}}

      iex> create_translation_key(%{field: bad_value}, project_id)
      {:error, %Ecto.Changeset{}}

      iex> create_translation_key(%{field: value}, bad_value)
      {:error, %Ecto.Changeset{}}

  """
  def create_translation_key(attrs \\ %{}, project_id) do
    changeset = Map.put(attrs, :project_id, project_id) |> Utilities.key_to_atom()
    create_translation_key(changeset)
  end

  @doc """
  Creates a default translation for translation_key.

  ## Examples

      iex> create_default_translation({:ok, %TranslationKey{}})
      {:ok, %TranslationKey{}}

  """
  def create_default_translation({:ok, %TranslationKey{} = translation_key}) do
    default_locale = get_default_locale!(translation_key.project_id)

    create_translation(
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
    translation_key
    |> TranslationKey.update_changeset(attrs)
    |> Repo.update()
    |> StatisticsInterface.update_statistics(:translation_key, :update)
    |> update_default_translation_if_translation_key_was_updated(attrs)
  end

  defp update_default_translation_if_translation_key_was_updated({:ok, translation_key}, attrs) do
    attrs = Utilities.key_to_atom(attrs)

    get_default_translation(translation_key.id)
    |> Translation.changeset(%{value: attrs.default_value})
    |> Repo.update()

    {:ok, Map.put(translation_key, :default_value, attrs.default_value)}
  end

  defp update_default_translation_if_translation_key_was_updated(response, _), do: response

  @doc """
  Deletes a TranslationKey.

  ## Examples

      iex> delete_translation_key(translation_key)
      {:ok, %TranslationKey{}}

      iex> delete_translation_key(translation_key)
      {:error, %Ecto.Changeset{}}

  """
  def delete_translation_key(%TranslationKey{} = translation_key) do
    translation_key
    |> TranslationKey.update_changeset(%{is_removed: true})
    |> Repo.update()
    |> StatisticsInterface.update_statistics(:translation_key, :delete)
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
    translation_key
    |> TranslationKey.remove_changeset()
    |> Repo.update()
    |> StatisticsInterface.update_statistics(:translation_key, :delete)
  end

  @doc """
  Restore a TranslationKey.

  ## Examples

      iex> safely_delete_translation_key(translation_key)
      {:ok, %TranslationKey{}}

      iex> safely_delete_translation_key(translation_key)
      {:error, %Ecto.Changeset{}}

  """
  def restore_translation_key(%TranslationKey{} = translation_key) do
    translation_key
    |> TranslationKey.remove_changeset()
    |> Repo.update()
    |> StatisticsInterface.update_statistics(:translation_key, :create)
  end

  # deprecated
  @doc """
  Returns an `%Ecto.Changeset{}` for tracking translation_key changes.

  ## Examples

      iex> change_translation_key(translation_key)
      %Ecto.Changeset{source: %TranslationKey{}}

  """
  def change_translation_key(%TranslationKey{} = translation_key) do
    TranslationKey.update_changeset(translation_key, %{})
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
    from(
      p in Translation,
      join: pr in I18NAPI.Translations.Locale,
      on: p.locale_id == pr.id,
      where: pr.id == ^locale_id
    )
    |> Repo.all()
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
  Gets a single translation.

  Return nil if the Translation does not exist.

  ## Examples

      iex> get_translation(123, 321)
      %Translation{}

      iex> get_translation(456, 654)
      nil

  """
  def get_translation(translation_key_id, locale_id) do
    from(
      Translation,
      where: [translation_key_id: ^translation_key_id, locale_id: ^locale_id]
    )
    |> Repo.one()
  end

  @doc """
  Creates a translation.

  ## Examples

      iex> create_translation(%{field: value}, 1)
      {:ok, %Translation{}}

      iex> create_translation(%{field: bad_value}, 1)
      {:error, %Ecto.Changeset{}}

  """
  def create_translation(attrs) do
    %Translation{}
    |> Translation.changeset(attrs)
    |> Repo.insert()
    |> StatisticsInterface.update_statistics(:translation, :create, :empty, attrs)
  end

  def create_translation(attrs, locale_id) do
    Map.put(attrs, :locale_id, locale_id)
    |> Utilities.key_to_atom()
    |> create_translation()
  end

  @doc """
  Updates a translation.

  ## Examples

      iex> update_translation(translation, %{field: new_value})
      {:ok, %Translation{}}

      iex> update_translation(translation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_translation(%Translation{} = translation, attrs \\ %{}) do
    attrs =
      attrs
      |> Map.take(["status", "value", :status, :value])
      |> Utilities.key_to_atom()

    translation
    |> Translation.changeset(attrs)
    |> Repo.update()
    |> if_default_translation_changed_successfully(translation.value, attrs)
    |> StatisticsInterface.update_statistics(:translation, :update, translation.status, attrs)
  end

  defp if_default_translation_changed_successfully(
         {:ok, translation},
         old_value,
         attrs
       ) do
    with true <- is_default_locale?(translation.locale_id),
         true <- Map.has_key?(attrs, :value),
         true <- old_value != attrs.value,
         do:
           set_all_nondefault_translations_for_this_key_as_unverified(
             translation.translation_key_id
           )

    {:ok, translation}
  end

  defp if_default_translation_changed_successfully(response, _, _), do: response

  defp is_default_locale?(locale_id) do
    from(
      locl in Locale,
      select: locl.is_default,
      where: locl.id == ^locale_id
    )
    |> Repo.one!()
  end

  defp set_all_nondefault_translations_for_this_key_as_unverified(translation_key_id) do
    from(
      tr in Translation,
      join: lcl in Locale,
      on: lcl.id == tr.locale_id,
      where: tr.translation_key_id == ^translation_key_id and not lcl.is_default
    )
    |> Repo.update_all(
      set: [
        status: "unverified"
      ]
    )
    |> StatisticsInterface.update_statistics(:translation_key, :update)
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
    |> StatisticsInterface.update_statistics(:translation, :delete, translation.id)
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
    translation
    |> Translation.changeset(%{value: nil})
    |> Repo.update()
    |> StatisticsInterface.update_statistics(:translation, :delete, translation.id)
  end

  # deprecated
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
  Get all translation_keys and translations for locale

  ## Example

      iex> get_keys_and_translations(locale)
      {:ok, %TranslationKey{}}
  """
  def get_keys_and_translations(locale) do
    default_locale = get_default_locale!(locale.project_id)
    default_translations = list_translations(default_locale.id)
    current_translations = list_translations(locale.id)

    list_translation_keys(default_locale.project_id)
    |> Enum.map(fn key ->
      %{
        translation_key_id: key.id,
        key: key.key,
        context: key.context,
        default_value: get_translation_value(default_translations, key.id),
        current_value: get_translation_value(current_translations, key.id)
      }
    end)
  end

  defp get_translation_value(translations, key_id) do
    translation =
      Enum.filter(translations, fn x -> x.translation_key_id == key_id end)
      |> List.first()

    if translation do
      %{id: translation.id, value: translation.value}
    else
      nil
    end
  end

  def get_default_translation(key_id) do
    from(
      tr in Translation,
      join: locl in Locale,
      on: [
        id: tr.locale_id
      ],
      where: tr.translation_key_id == ^key_id and locl.is_default == true
    )
    |> Repo.one()
  end

  def get_default_translation_value(key_id) do
    from(
      tr in Translation,
      join: locl in Locale,
      on: [
        id: tr.locale_id
      ],
      select: tr.value,
      where: tr.translation_key_id == ^key_id and locl.is_default == true
    )
    |> Repo.one()
  end

  @doc """
  Returns the list of user_locales.

  ## Examples

      iex> list_user_locales()
      [%UserLocale{}, ...]

  """
  def list_user_locales do
    Repo.all(UserLocale)
  end

  @doc """
  Returns the list of user_locales then is_removed == false.

  ## Examples

      iex> list_user_locales_not_removed()
      [%UserLocale{}, ...]

  """
  def list_user_locales_not_removed do
    from(UserLocale, where: [is_removed: false]) |> Repo.all()
  end

  @doc """
  Gets a single user_locales.

  Raises `Ecto.NoResultsError` if the User locales does not exist.

  ## Examples

      iex> get_user_locale!(123)
      %UserLocale{}

      iex> get_user_locale!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_locale!(id), do: Repo.get!(UserLocale, id)

  @doc """
  Gets a single user_locales.

  Return nil if the User locales does not exist.

  ## Examples

      iex> get_user_locale!(123)
      %UserLocale{}

      iex> get_user_locale!(456)
      nil

  """
  def get_user_locale(id), do: Repo.get(UserLocale, id)

  @doc """
  Gets a single user_locales then is_removed == false.

  Raises `Ecto.NoResultsError` if the User locales does not exist.

  ## Examples

      iex> get_user_locale_not_removed!(123)
      %UserLocale{}

      iex> get_user_locale_not_removed!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_locale_not_removed!(id) do
    from(UserLocale, where: [id: ^id, is_removed: false])
    |> Repo.one!()
  end

  @doc """
  Gets a single user_locales then is_removed == false.

  Return nil if the User locales does not exist.

  ## Examples

      iex> get_user_locale_not_removed!(123)
      %UserLocale{}

      iex> get_user_locale_not_removed!(456)
      nil

  """
  def get_user_locale_not_removed(id) do
    from(UserLocale, where: [id: ^id, is_removed: false])
    |> Repo.one()
  end

  @doc """
  Gets a single user_locales.

  Raises `Ecto.NoResultsError` if the User locales does not exist.

  ## Examples

      iex> get_user_locale!(123, 321)
      %UserLocale{}

      iex> get_user_locale!(456, 654)
      ** (Ecto.NoResultsError)

  """
  def get_user_locale!(locale_id, user_id) do
    from(
      ul in UserLocale,
      where: ul.locale_id == ^locale_id and ul.user_id == ^user_id
    )
    |> Repo.one!()
  end

  @doc """
  Gets a single user_locales.

  Return nil if the User locales does not exist.

  ## Examples

      iex> get_user_locale(123, 321)
      %UserLocale{}

      iex> get_user_locale(456, 654)
      nil

  """
  def get_user_locale(locale_id, user_id) do
    from(
      ul in UserLocale,
      where: ul.locale_id == ^locale_id and ul.user_id == ^user_id
    )
    |> Repo.one()
  end

  @doc """
  Creates a user_locales.

  ## Examples

      iex> create_user_locale(%{field: value})
      {:ok, %UserLocale{}}

      iex> create_user_locale(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_locale(attrs \\ %{}) do
    %UserLocale{}
    |> UserLocale.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_locales.

  ## Examples

      iex> update_user_locale(user_locales, %{field: new_value})
      {:ok, %UserLocale{}}

      iex> update_user_locale(user_locales, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_locale(%UserLocale{} = user_locales, attrs) do
    user_locales
    |> UserLocale.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a UserLocale.

  ## Examples

      iex> delete_user_locale(user_locales)
      {:ok, %UserLocale{}}

      iex> delete_user_locale(user_locales)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_locale(%UserLocale{} = user_locales), do: Repo.delete(user_locales)

  @doc """
  Safely Deletes a UserLocale.

  ## Examples

      iex> safely_delete_user_locale(user_locales)
      {:ok, %UserLocale{}}

      iex> safely_delete_user_locale(user_locales)
      {:error, %Ecto.Changeset{}}

  """
  def safely_delete_user_locale(%UserLocale{} = user_locales) do
    user_locales
    |> UserLocale.remove_changeset()
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_locales changes.

  ## Examples

      iex> change_user_locales(user_locales)
      %Ecto.Changeset{source: %UserLocale{}}

  """
  def change_user_locales(%UserLocale{} = user_locales) do
    UserLocale.update_changeset(user_locales, %{})
  end
end
