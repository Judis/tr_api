defmodule I18NAPI.Translations.StatisticsInterface do
  @moduledoc """
  Interface for I18NAPI.Translations.StatisticsWatcher
  """
  alias I18NAPI.Translations.Statistics
  alias I18NAPI.Translations.StatisticsWatcherInterface

  # Project

  def update_statistics({:ok, project}, :project, _) do
    {:ok, project}
  end

  # Locale

  def update_statistics({:ok, locale}, :locale, _) do
    #    Statistics.update_all_locale_counts(locale.id, locale.project_id)
    #    Statistics.update_all_project_counts(locale.project_id)
    StatisticsWatcherInterface.recalculate_locale_statistics([], locale.id, locale.project_id)
    StatisticsWatcherInterface.recalculate_project_statistics([], locale.project_id)
    {:ok, locale}
  end

  # Translation_key

  def update_statistics({:ok, translation_key}, :translation_key, :create) do
    Statistics.update_total_count_of_translation_keys(translation_key.project_id, :inc)
    update_statistics({:ok, translation_key}, :translation_key, :update)
    {:ok, translation_key}
  end

  def update_statistics({:ok, translation_key}, :translation_key, :update) do
    #    Statistics.update_all_child_locales(translation_key.project_id)
    #    Statistics.update_all_project_counts(translation_key.project_id)
    StatisticsWatcherInterface.recalculate_statistics_all_child_locales_in_project(
      [],
      translation_key.project_id
    )

    StatisticsWatcherInterface.recalculate_project_statistics([], translation_key.project_id)
    {:ok, translation_key}
  end

  def update_statistics({:ok, translation_key}, :translation_key, :delete) do
    Statistics.update_total_count_of_translation_keys(translation_key.project_id, :dec)
    StatisticsWatcherInterface.recalculate_project_statistics([], translation_key.project_id)
    {:ok, translation_key}
  end

  # Translation

  def update_statistics({:ok, translation}, :translation, :create, old_status, changeset) do
    with true <- Map.has_key?(changeset, :status) do
      Statistics.update_count_choice_async(translation.locale_id, old_status, changeset.status)
    end

    StatisticsWatcherInterface.recalculate_statistics_parent_project_by_locale_id(
      [],
      translation.locale_id
    )

    {:ok, translation}
  end

  def update_statistics({:ok, translation}, :translation, :update, old_status, changeset) do
    with true <- Map.has_key?(changeset, :status) do
      Statistics.update_count_choice_async(translation.locale_id, old_status, changeset.status)
    end

    StatisticsWatcherInterface.recalculate_statistics_parent_project_by_locale_id(
      [],
      translation.locale_id
    )

    {:ok, translation}
  end

  def update_statistics({:ok, translation}, :translation, :delete) do
    StatisticsWatcherInterface.recalculate_locale_statistics(
      [],
      translation.id,
      translation.project_id
    )

    StatisticsWatcherInterface.recalculate_statistics_parent_project_by_locale_id(
      [],
      translation.locale_id
    )

    {:ok, translation}
  end

  def update_statistics({:error, _} = piped_data, _, _), do: piped_data
  def update_statistics({:error, _} = piped_data, _, _, _), do: piped_data
  def update_statistics({:error, _} = piped_data, _, _, _, _), do: piped_data

  def update_statistics(piped_data, _, _), do: piped_data
  def update_statistics(piped_data, _, _, _), do: piped_data
  def update_statistics(piped_data, _, _, _, _), do: piped_data
end
