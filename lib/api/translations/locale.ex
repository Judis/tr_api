defmodule I18NAPI.Translations.Locale do
  use Ecto.Schema
  import Ecto.Changeset
  alias I18NAPI.Projects.{UserLocales}

  schema "locales" do
    field(:is_default, :boolean, default: false)
    field(:is_removed, :boolean, default: false)
    field(:locale, :string)
    field(:removed_at, :naive_datetime)

    field(:count_of_not_verified_keys, :integer, default: 0)
    field(:count_of_verified_keys, :integer, default: 0)
    field(:count_of_translated_keys, :integer, default: 0)
    field(:count_of_untranslated_keys, :integer, default: 0)
    field(:count_of_keys_need_check, :integer, default: 0)

    belongs_to(:project, I18NAPI.Projects.Project)
    has_many(:user_locales, UserLocales, on_delete: :delete_all)
    has_many(:translations, I18NAPI.Translations.Translation)

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
    |> unique_constraint(:locale, name: :locales_project_id_locale_is_removed_index)
  end

  @doc false
  def remove_changeset(locale, attrs) do
    locale
    |> cast(attrs, [:is_removed, :removed_at])
    |> validate_required([:is_removed, :removed_at])
  end
end
