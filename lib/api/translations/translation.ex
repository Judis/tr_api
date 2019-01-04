defmodule I18NAPI.Translations.Translation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "translations" do
    field(:value, :string, default: nil)
    field(:locale_id, :id)
    field(:status, TranslationStatusEnum)
    field(:translation_key_id, :id)

    timestamps()
  end

  @doc false
  def changeset(translation, attrs) do
    translation
    |> cast(attrs, [:value, :locale_id, :status, :translation_key_id])
    |> validate_required([:value, :status, :locale_id, :translation_key_id])
    |> unique_constraint(:translation,
         name: :translations_locale_id_translation_key_id_is_removed_index
       )
  end
end
