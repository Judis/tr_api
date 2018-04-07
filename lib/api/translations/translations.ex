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
  def create_locale(attrs \\ %{}) do
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
  def create_translation_key(attrs \\ %{}) do
    %TranslationKey{}
    |> TranslationKey.changeset(attrs)
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
  Returns an `%Ecto.Changeset{}` for tracking translation_key changes.

  ## Examples

      iex> change_translation_key(translation_key)
      %Ecto.Changeset{source: %TranslationKey{}}

  """
  def change_translation_key(%TranslationKey{} = translation_key) do
    TranslationKey.changeset(translation_key, %{})
  end
end
