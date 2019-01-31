defmodule I18NAPI.Translations.Export do
  @moduledoc """
  Export
  """
  import Ecto.Query, warn: false

  alias I18NAPI.Composers
  alias I18NAPI.Repo
  alias I18NAPI.Utilities
  alias I18NAPI.Translations
  alias I18NAPI.Translations.{Locale, Translation, TranslationKey}

  def export_locale(locale_id, ext) do
    with atom_ext <- String.to_existing_atom(ext),
         true <- is_atom(atom_ext),
         [module] <- Composers.get_module(atom_ext) do
      Translations.list_translation_keys_with_values(locale_id)
      |> Composers.compose(atom_ext)
    else
      _ -> {:error, :composer_not_defined}
    end
  end
end
