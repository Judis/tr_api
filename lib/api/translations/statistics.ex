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
        :verified     -> Repo.update_all(query, inc: [count_of_verified_keys: value])
        :not_verified -> Repo.update_all(query, inc: [count_of_not_verified_keys: value])
        :need_check   -> Repo.update_all(query, inc: [count_of_keys_need_check: value])
      end
    end)
  end

end