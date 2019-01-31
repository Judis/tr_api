defmodule I18NAPI.Translations.Import do
  @moduledoc """
  Import
  """
  import Ecto.Query, warn: false

  alias I18NAPI.Repo
  alias I18NAPI.Utilities
  alias I18NAPI.Translations
  alias I18NAPI.Translations.{Locale, StatisticsInterface, Translation, TranslationKey}

  def import_locale(locale_id, data) do
    with %Locale{} = locale <- Translations.get_locale(locale_id) do
        data
        |> Enum.each(fn {key, value} ->
          {key, value, locale}
          |> process_translation_key()
          |> process_translation()
        end)

      {:ok, locale}
      |> StatisticsInterface.update_statistics(:locale, :update)
    else
      _ -> {:error, :unknown_locale}
    end
  end

  def process_translation_key({key, value, locale}) do
    with %Locale{} <- locale do
      t_key =
        key
        |> Translations.get_translation_key_by_key(locale.project_id)
        |> create_new_translation_key_if_not_exists(%{
          project_id: locale.project_id,
          context: "",
          key: key,
          default_value:
            if(locale.is_default) do
              value
            end
        })

      {t_key, value, locale}
    else
      _ -> {:error, :bad_locale}
    end
  end

  def create_new_translation_key_if_not_exists(%TranslationKey{} = t_key, _), do: t_key

  def create_new_translation_key_if_not_exists(t_key, attrs) do
    {:ok, t_key} = Translations.import_translation_key(attrs)
    t_key
  end

  def process_translation({:error, e}), do: {:error, e}

  def process_translation({t_key, value, locale}) do
    with %Locale{} <- locale,
         %TranslationKey{} <- t_key,
         %Translation{} <- translation = Translations.get_translation(t_key.id, locale.id) do
      translation
      |> Translations.update_translation(%{
        value: value,
        status: :verified
      })
    else
      _ -> {:error, :bad_request}
    end
  end
end
