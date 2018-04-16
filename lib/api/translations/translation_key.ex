defmodule I18NAPI.Translations.TranslationKey do
  use Ecto.Schema
  import Ecto.Changeset

  schema "translation_keys" do
    field(:context, :string)
    field(:is_removed, :boolean, default: false)
    field(:key, :string)
    field(:removed_at, :naive_datetime)
    field(:status, :integer)
    field(:value, :string)

    belongs_to(:locale, I18NAPI.Translations.Locale)

    timestamps()
  end

  @doc false
  def changeset(translation_key, attrs) do
    translation_key
    |> cast(attrs, [:key, :value, :context, :status, :is_removed, :removed_at])
    |> validate_required([:key, :value])
    |> unique_constraint(:key, name: :translation_keys_locale_id_key_is_removed_index)
  end
end
