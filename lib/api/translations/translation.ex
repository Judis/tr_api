defmodule I18NAPI.Translations.Translation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "translations" do
    field(:is_removed, :boolean, default: false)
    field(:removed_at, :naive_datetime)
    field(:value, :string)
    field(:locale_id, :id)
    field(:translation_key_id, :id)

    timestamps()
  end

  @doc false
  def changeset(translation, attrs) do
    translation
    |> cast(attrs, [:value, :locale_id, :translation_key_id, :is_removed, :removed_at])
    |> validate_required([:value, :locale_id, :translation_key_id])
    |> unique_constraint(
      :translation,
      name: :translations_locale_id_translation_key_id_is_removed_index
    )
  end

  @doc false
  def remove_changeset(translation, attrs) do
    translation
    |> cast(attrs, [:is_removed, :removed_at])
    |> validate_required([:is_removed, :removed_at])
  end
end
