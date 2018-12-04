defmodule I18NAPI.Translations.Statistics do
  @moduledoc """
  The Translations context.
  """
  import Ecto.Query, warn: false
  alias I18NAPI.Repo
  alias I18NAPI.Utilites
  alias I18NAPI.Projects
  alias I18NAPI.Projects.Project
  alias I18NAPI.Translations.Locale
  alias I18NAPI.Translations.Translation

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

    Task.async(fn ->
      query = from(p in Project, where: [id: ^project_id])
      Repo.update_all(query, inc: [total_count_of_translation_keys: value])
    end)
  end

  def recalculate_count_of_untranslated_keys_at_locales(project_id) do
    Task.async(fn ->
      Repo.transaction(fn ->
        total = Projects.get_total_count_of_translation_keys(project_id)

        from(l in Locale, where: [project_id: ^project_id],
        update: [set: [count_of_untranslated_keys: fragment("(? - ?)", ^total, l.count_of_translated_keys)]])
        |> Repo.update_all([])

      end)
    end)
  end

  def update_count_of_keys_at_locales(locale_id, operation, key, value \\ 1)
  def update_count_of_keys_at_locales(locale_id, operation, key, value)
      when ((:inc == operation) or (:dec == operation))
           and is_integer(value) do
    if (:dec == operation), do: value = -value
    query = from(l in Locale, where: [id: ^locale_id])

    Task.async(fn ->
      case key do
        :translated   -> Repo.update_all(query, inc: [count_of_translated_keys: value])
        :untranslated -> Repo.update_all(query, inc: [count_of_untranslated_keys: value])
        :verified     -> Repo.update_all(query, inc: [count_of_verified_keys: value])
        :not_verified -> Repo.update_all(query, inc: [count_of_not_verified_keys: value])
        :need_check   -> Repo.update_all(query, inc: [count_of_keys_need_check: value])
      end
    end)
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

      {:unverified, :empty} -> fn ->
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

      {:verified, :empty} -> fn ->
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

      {:need_check, :empty} -> fn ->
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

    end
  end

end