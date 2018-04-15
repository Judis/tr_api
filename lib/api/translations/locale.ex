defmodule I18NAPI.Translations.Locale do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locales" do
    field(:count_of_keys, :integer)
    field(:count_of_translated_keys, :integer)
    field(:count_of_words, :integer)
    field(:is_default, :boolean, default: false)
    field(:is_removed, :boolean, default: false)
    field(:locale, :string)
    field(:removed_at, :naive_datetime)
    field(:project_id, :id)

    timestamps()
  end

  @doc false
  def changeset(locale, attrs) do
    locale
    |> cast(attrs, [
      :locale,
      :is_default,
      :count_of_keys,
      :count_of_words,
      :count_of_translated_keys,
      :is_removed,
      :removed_at
    ])
    |> validate_required([
      :locale,
      :is_default,
      :count_of_keys,
      :count_of_words,
      :count_of_translated_keys,
      :is_removed,
      :removed_at
    ])
  end
end
