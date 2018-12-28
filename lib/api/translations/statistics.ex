defmodule I18NAPI.Translations.Statistics do
  @moduledoc """
  The Translations context.
  """
  import Ecto.Query, warn: false
  alias I18NAPI.Repo
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

  def update_total_count_of_translation_keys(project_id, :dec, value) when is_integer(value) do
    update_total_count_of_translation_keys(project_id, :inc, value * -1)
  end

  def update_total_count_of_translation_keys(project_id, :inc, value) when is_integer(value) do
    from(
      p in Project,
      where: [
        id: ^project_id
      ]
    )
    |> Repo.update_all(
      inc: [
        total_count_of_translation_keys: value
      ]
    )
  end

  def update_total_count_of_translation_keys_async(project_id, operation, value) do
    spawn(
      I18NAPI.Translations.Statistics,
      :update_total_count_of_translation_keys,
      [project_id, operation, value]
    )
  end

  def update_basic_statistics(project_id, operation, value \\ 1) do
    update_total_count_of_translation_keys(project_id, operation, value)
    recalculate_count_of_untranslated_keys_at_locales(project_id)
  end

  def update_basic_statistics_async(project_id, operation, value \\ 1) do
    spawn(
      I18NAPI.Translations.Statistics,
      :update_basic_statistics,
      [
        project_id,
        operation,
        value
      ]
    )
  end

  def recalculate_count_of_untranslated_keys_at_locales(project_id) do
    Repo.transaction(fn ->
      total = Projects.get_total_count_of_translation_keys(project_id)

      from(
        l in Locale,
        where: [
          project_id: ^project_id
        ],
        update: [
          set: [
            count_of_untranslated_keys: fragment("(? - ?)", ^total, l.count_of_translated_keys)
          ]
        ]
      )
      |> Repo.update_all([])
    end)
  end

  def recalculate_count_of_untranslated_keys_at_locales_async(project_id) do
    spawn(
      I18NAPI.Translations.Statistics,
      :recalculate_count_of_untranslated_keys_at_locales,
      [
        project_id
      ]
    )
  end

  def update_count_of_keys_at_locales(locale_id, operation, key, value \\ 1)

  def update_count_of_keys_at_locales(locale_id, :dec, key, value) when is_integer(value) do
    update_count_of_keys_at_locales(locale_id, :inc, key, value * -1)
  end

  def update_count_of_keys_at_locales(locale_id, :inc, key, value) when is_integer(value) do
    counter_key =
      case key do
        :translated -> :count_of_translated_keys
        :untranslated -> :count_of_untranslated_keys
        :verified -> :count_of_verified_keys
        :not_verified -> :count_of_not_verified_keys
      end

    from(
      l in Locale,
      where: [
        id: ^locale_id
      ]
    )
    |> Repo.update_all(inc: Keyword.new([{counter_key, value}]))
  end

  def update_count_of_keys_at_locales_async(locale_id, operation, key, value \\ 1)

  def update_count_of_keys_at_locales_async(locale_id, operation, key, value) do
    spawn(
      I18NAPI.Translations.Statistics,
      :update_count_of_keys_at_locales,
      [locale_id, operation, key, value]
    )
  end

  def update_count_choice(locale_id, prev_status, new_status) do
    case prev_status do
      :empty ->
        update_count_of_keys_at_locales(locale_id, :inc, :translated)
        update_count_of_keys_at_locales(locale_id, :dec, :untranslated)

      :unverified ->
        update_count_of_keys_at_locales(locale_id, :dec, :not_verified)

      :verified ->
        update_count_of_keys_at_locales(locale_id, :dec, :verified)

      _ ->
        nil
    end

    case new_status do
      :empty ->
        update_count_of_keys_at_locales(locale_id, :dec, :translated)
        update_count_of_keys_at_locales(locale_id, :inc, :untranslated)

      :unverified ->
        update_count_of_keys_at_locales(locale_id, :inc, :not_verified)

      :verified ->
        update_count_of_keys_at_locales(locale_id, :inc, :verified)

      _ ->
        nil
    end
  end

  def update_count_choice_async(locale_id, prev_status, new_status) do
    spawn(
      I18NAPI.Translations.Statistics,
      :update_count_choice,
      [locale_id, prev_status, new_status]
    )
  end

  def calculate_count_of_keys_at_locale_by_status(locale_id, status, is_removed \\ false) do
    from(
      t in Translation,
      where: [
        locale_id: ^locale_id
      ],
      where: [
        status: ^status
      ],
      where: [
        is_removed: ^is_removed
      ],
      select: count(t.id)
    )
    |> Repo.one!()
  end

  def calculate_total_count_of_translation_keys_at_project(project_id, is_removed \\ false) do
    from(
      tk in TranslationKey,
      where: [
        project_id: ^project_id
      ],
      where: [
        is_removed: ^is_removed
      ],
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
    project_id =
      unless is_integer(project_id) do
        Translations.get_locale!(locale_id).id
      else
        project_id
      end

    Repo.transaction(fn ->
      total = Projects.get_total_count_of_translation_keys(project_id)
      verified = calculate_count_of_keys_at_locale_by_status(locale_id, :verified, false)
      unverified = calculate_count_of_keys_at_locale_by_status(locale_id, :unverified, false)
      translated = verified + unverified
      untranslated = total - translated

      from(
        l in Locale,
        where: [
          id: ^locale_id
        ],
        update: [
          set: [
            total_count_of_translation_keys: ^total,
            count_of_verified_keys: ^verified,
            count_of_not_verified_keys: ^unverified,
            count_of_translated_keys: ^translated,
            count_of_untranslated_keys: ^untranslated
          ]
        ]
      )
      |> Repo.update_all([])
    end)
  end

  @doc """
  Updated all statistics fields on all child locales for this project

  ## Examples

      iex> update_all_child_locales(project_id)

  """
  def update_all_child_locales(project_id) do
    total = Projects.get_total_count_of_translation_keys(project_id)

    Translations.list_locale_identities(project_id)
    |> process_update_locales_by_id_list(total)
  end

  defp process_update_locales_by_id_list([], _), do: []

  defp process_update_locales_by_id_list([locale_id | tail], total_counts) do
    Repo.transaction(fn ->
      verified = calculate_count_of_keys_at_locale_by_status(locale_id, :verified, false)
      unverified = calculate_count_of_keys_at_locale_by_status(locale_id, :unverified, false)
      translated = verified + unverified
      untranslated = total_counts - translated

      from(
        l in Locale,
        where: [
          id: ^locale_id
        ],
        update: [
          set: [
            total_count_of_translation_keys: ^total_counts,
            count_of_verified_keys: ^verified,
            count_of_not_verified_keys: ^unverified,
            count_of_translated_keys: ^translated,
            count_of_untranslated_keys: ^untranslated
          ]
        ]
      )
      |> Repo.update_all([])
    end)

    process_update_locales_by_id_list(tail, total_counts)
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

  def update_all_project_counts_by_locale_id(locale_id) do
    Translations.get_locale!(locale_id).project_id
    |> update_all_project_counts()
  end

  def update_all_project_counts(project_id) do
    Repo.transaction(fn ->
      total = calculate_total_count_of_translation_keys_at_project(project_id, false)

      locales_summary =
        from(
          l in Locale,
          where: [
            project_id: ^project_id
          ],
          select: %{
            verified: sum(l.count_of_verified_keys),
            unverified: sum(l.count_of_not_verified_keys),
            translated: sum(l.count_of_translated_keys),
            untranslated: sum(l.count_of_untranslated_keys)
          }
        )

      from(
        p in Project,
        join: locale in subquery(locales_summary),
        where: [
          id: ^project_id
        ],
        update: [
          set: [
            total_count_of_translation_keys: ^total,
            count_of_verified_keys: locale.verified,
            count_of_not_verified_keys: locale.unverified,
            count_of_translated_keys: locale.translated,
            count_of_untranslated_keys: locale.untranslated
          ]
        ]
      )
      |> Repo.update_all([])
    end)
  end

  def update_all_project_counts_async(project_id) do
    spawn(I18NAPI.Translations.Statistics, :update_all_project_counts, [project_id])
  end
end
