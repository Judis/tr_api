defmodule I18NAPI.Translations.Statistics do
  @moduledoc """
  The Translations context.
  """
  import Ecto.Query, warn: false
  alias I18NAPI.Repo
  alias I18NAPI.Utilites
  alias I18NAPI.Projects
  alias I18NAPI.Projects.Project
  alias I18NAPI.Translations
  alias I18NAPI.Translations.{Locale, Translation, TranslationKey}

  @doc """
  Inc/decrement a project field :total_count_of_translation_keys.

  ## Examples

      iex> update_total_count_of_translation_keys(project_id)
      {:ok, %Project{}}

      iex> update_total_count_of_translation_keys(project_id, :dec)
      {:ok, %Project{}}

  """
  def update_total_count_of_translation_keys(project_id, operation, value \\ 1)
  def update_total_count_of_translation_keys(project_id, operation, value)
      when ((:inc == operation) or (:dec == operation)) and is_integer(value) do
    if (:dec == operation), do: value = -value

      query = from(p in Project, where: [id: ^project_id])
      Repo.update_all(query, inc: [total_count_of_translation_keys: value])
  end

  def update_total_count_of_translation_keys_async(project_id, operation, value \\ 1)
  def update_total_count_of_translation_keys_async(project_id, operation, value) do
    spawn(I18NAPI.Translations.Statistics, :update_total_count_of_translation_keys, [project_id, operation, value])
  end

  def update_basic_statistics(project_id, operation, value \\ 1)
  def update_basic_statistics(project_id, operation, value) do
    update_total_count_of_translation_keys(project_id, operation, value)
    recalculate_count_of_untranslated_keys_at_locales(project_id)
  end

  def update_basic_statistics_async(project_id, operation, value \\ 1)
  def update_basic_statistics_async(project_id, operation, value) do
    spawn(I18NAPI.Translations.Statistics, :update_basic_statistics, [project_id, operation, value])
  end

  def recalculate_count_of_untranslated_keys_at_locales(project_id) do
      Repo.transaction(fn ->
        total = Projects.get_total_count_of_translation_keys(project_id)

        from(l in Locale, where: [project_id: ^project_id],
        update: [set: [count_of_untranslated_keys: fragment("(? - ?)", ^total, l.count_of_translated_keys)]])
        |> Repo.update_all([])

      end)
  end

  def recalculate_count_of_untranslated_keys_at_locales_async(project_id) do
    spawn(I18NAPI.Translations.Statistics, :recalculate_count_of_untranslated_keys_at_locales, [project_id])
  end

  def update_count_of_keys_at_locales(locale_id, operation, key, value \\ 1)
  def update_count_of_keys_at_locales(locale_id, operation, key, value)
      when ((:inc == operation) or (:dec == operation))
           and is_integer(value) do

    if (:dec == operation), do: value = -value
    query = from(l in Locale, where: [id: ^locale_id])

      case key do
        :translated   -> Repo.update_all(query, inc: [count_of_translated_keys: value])
        :untranslated -> Repo.update_all(query, inc: [count_of_untranslated_keys: value])
        :verified     -> Repo.update_all(query, inc: [count_of_verified_keys: value])
        :not_verified -> Repo.update_all(query, inc: [count_of_not_verified_keys: value])
        :need_check   -> Repo.update_all(query, inc: [count_of_keys_need_check: value])
      end
  end

  def update_count_of_keys_at_locales_async(locale_id, operation, key, value \\ 1)
  def update_count_of_keys_at_locales_async(locale_id, operation, key, value) do
    spawn(I18NAPI.Translations.Statistics, :update_count_of_keys_at_locales, [locale_id, operation, value])
  end

  def update_count_choice(locale_id, prev_status, new_status) do
    case {prev_status, new_status} do
      {:empty, :unverified} ->
        update_count_of_keys_at_locales(locale_id, :inc, :translated)
        update_count_of_keys_at_locales(locale_id, :dec, :untranslated)
        update_count_of_keys_at_locales(locale_id, :inc, :not_verified)

      {:empty, :verified} ->
        update_count_of_keys_at_locales(locale_id, :inc, :translated)
        update_count_of_keys_at_locales(locale_id, :dec, :untranslated)
        update_count_of_keys_at_locales(locale_id, :inc, :verified)

      {:empty, :need_check} ->
        update_count_of_keys_at_locales(locale_id, :inc, :untranslated)
        update_count_of_keys_at_locales(locale_id, :inc, :need_check)

      {:unverified, :empty} ->
        update_count_of_keys_at_locales(locale_id, :dec, :translated)
        update_count_of_keys_at_locales(locale_id, :inc, :untranslated)
        update_count_of_keys_at_locales(locale_id, :dec, :not_verified)

      {:unverified, :verified} ->
        update_count_of_keys_at_locales(locale_id, :dec, :not_verified)
        update_count_of_keys_at_locales(locale_id, :inc, :verified)

      {:unverified, :need_check} ->
        update_count_of_keys_at_locales(locale_id, :dec, :translated)
        update_count_of_keys_at_locales(locale_id, :inc, :untranslated)
        update_count_of_keys_at_locales(locale_id, :dec, :not_verified)
        update_count_of_keys_at_locales(locale_id, :inc, :need_check)

      {:verified, :empty} ->
        update_count_of_keys_at_locales(locale_id, :dec, :translated)
        update_count_of_keys_at_locales(locale_id, :inc, :untranslated)
        update_count_of_keys_at_locales(locale_id, :dec, :verified)

      {:verified, :unverified} ->
        update_count_of_keys_at_locales(locale_id, :dec, :not_verified)
        update_count_of_keys_at_locales(locale_id, :inc, :verified)

      {:verified, :need_check} ->
        update_count_of_keys_at_locales(locale_id, :dec, :translated)
        update_count_of_keys_at_locales(locale_id, :inc, :untranslated)
        update_count_of_keys_at_locales(locale_id, :dec, :verified)
        update_count_of_keys_at_locales(locale_id, :inc, :need_check)

      {:need_check, :empty} ->
        update_count_of_keys_at_locales(locale_id, :dec, :untranslated)
        update_count_of_keys_at_locales(locale_id, :dec, :need_check)

      {:need_check, :verified} ->
        update_count_of_keys_at_locales(locale_id, :inc, :translated)
        update_count_of_keys_at_locales(locale_id, :dec, :untranslated)
        update_count_of_keys_at_locales(locale_id, :dec, :need_check)
        update_count_of_keys_at_locales(locale_id, :inc, :verified)

      {:need_check, :unverified} ->
        update_count_of_keys_at_locales(locale_id, :inc, :translated)
        update_count_of_keys_at_locales(locale_id, :dec, :untranslated)
        update_count_of_keys_at_locales(locale_id, :dec, :need_check)
        update_count_of_keys_at_locales(locale_id, :inc, :not_verified)

        _ ->
    end
  end

  def update_count_choice_async(locale_id, prev_status, new_status) do
    spawn(I18NAPI.Translations.Statistics, :update_count_choice, [locale_id, prev_status, new_status])
  end

  def calculate_count_of_keys_at_locale_by_status(locale_id, status, is_removed \\ false) do
    from(
      t in Translation,
      where: [locale_id: ^locale_id],
      where: [status: ^status],
      where: [is_removed: ^is_removed],
      select: count(t.id)
    )
    |> Repo.one!()
  end

  def calculate_total_count_of_translation_keys_at_project(project_id, is_removed \\ false) do
    from(
      tk in TranslationKey,
      where: [project_id: ^project_id],
      where: [is_removed: ^is_removed],
      select: count(tk.id)
    )
    |> Repo.one!()
  end

  @doc """
  Updated all statistics fields on locale

  If not transmit project_id field, function will get additional query to Locale

  ## Examples

      iex> update_all_locale_counts(locale_id, project_id)

      iex> update_all_locale_counts(locale_id)

  """
  def update_all_locale_counts(locale_id, project_id \\ nil) do
    project_id = unless is_integer(project_id) do
      project_id = Translations.get_locale!(locale_id).id
    else
      project_id
    end

    Repo.transaction(fn ->
      total = Projects.get_total_count_of_translation_keys(project_id)
      verified = calculate_count_of_keys_at_locale_by_status(locale_id, :verified, false)
      unverified = calculate_count_of_keys_at_locale_by_status(locale_id, :unverified, false)
      translated = verified + unverified
      untranslated = total - translated

      from(l in Locale,
        where: [id: ^locale_id],
        update: [set: [
          total_count_of_translation_keys: ^total,
          count_of_verified_keys: ^verified,
          count_of_not_verified_keys: ^unverified,
          count_of_translated_keys: ^translated,
          count_of_untranslated_keys: ^untranslated
        ]])
      |> Repo.update_all([])
    end)
  end

  @doc """
  Async updated all statistics fields on locale

  If not transmit project_id field, function will get additional query to Locale

  ## Examples

      iex> update_all_locale_counts_async(locale_id, project_id)

      iex> update_all_locale_counts_async(locale_id)

  """
  def update_all_locale_counts_async(locale_id, project_id \\ nil) do
    spawn(I18NAPI.Translations.Statistics, :update_all_locale_counts, [locale_id, project_id])
  end

  def calculate_count_of_keys_at_all_locales_for_project_by_status(project_id, status, is_removed \\ false) do
    from(
      p in Project,
      where: [project_id: ^project_id],
      where: [status: ^status],
      where: [is_removed: ^is_removed],
      select: count(t.id)
    )
    |> Repo.one!()
  end

  def update_all_project_counts(project_id) do
    Repo.transaction(fn ->
      total = calculate_total_count_of_translation_keys_at_project(project_id, false)
      # verified = calculate_count_of_keys_at_ ALL LOCALES(project_id, :verified)
      # unverified = calculate_count_of_keys_at ALL LOCALES(project_id, :unverified)
      # translated = verified + unverified
      # untranslated = total - translated

      from(p in Project,
        where: [id: ^project_id],
        update: [set: [
          total_count_of_translation_keys: ^total
          #count_of_verified_keys: ^verified,
          #count_of_not_verified_keys: ^unverified,
          #count_of_translated_keys: ^translated,
          #count_of_untranslated_keys: ^untranslated
        ]])
      |> Repo.update_all([])
    end)
  end


end