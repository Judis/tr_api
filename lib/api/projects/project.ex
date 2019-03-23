defmodule I18NAPI.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias I18NAPI.Projects.{UserRole}
  alias I18NAPI.Translations.{Locale, TranslationKey}
  alias I18NAPI.Utilities

  schema "projects" do
    field(:is_removed, :boolean, default: false)
    field(:name, :string)
    field(:removed_at, :naive_datetime)
    field(:default_locale, :string, virtual: true)

    field(:total_count_of_translation_keys, :integer, default: 0)
    field(:count_of_not_verified_keys, :integer, default: 0)
    field(:count_of_verified_keys, :integer, default: 0)
    field(:count_of_translated_keys, :integer, default: 0)
    field(:count_of_untranslated_keys, :integer, default: 0)

    has_many(:user_roles, UserRole, on_delete: :delete_all)
    has_many(:locales, Locale, on_delete: :delete_all)
    has_many(:translation_keys, TranslationKey, on_delete: :delete_all)

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :default_locale])
    |> validate_required([:name, :default_locale])
    |> validate_length(:name, min: 3, max: 255)
  end

  @doc false
  def remove_changeset(project) do
    project
    |> cast(%{is_removed: true, removed_at: Utilities.get_utc_now()}, [:is_removed, :removed_at])
    |> validate_required([:is_removed, :removed_at])
  end
end
