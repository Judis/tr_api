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

    belongs_to(:project, I18NAPI.Projects.Project)

    timestamps()
  end

  @doc false
  def changeset(locale, attrs) do
    locale
    |> cast(attrs, [
      :locale,
      :is_default,
      :project_id
    ])
    |> validate_required([
      :locale,
      :is_default,
      :project_id
    ])
    |> unique_constraint(:locale, name: :locales_project_id_locale_index)
  end
end
