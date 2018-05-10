defmodule I18NAPI.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias I18NAPI.Projects.{UserRoles}
  alias I18NAPI.Translations.{Locale, TranslationKey}

  schema "projects" do
    field(:is_removed, :boolean, default: false)
    field(:name, :string)
    field(:removed_at, :naive_datetime)
    field(:default_locale, :string, virtual: true)

    has_many(:user_roles, UserRoles)
    has_many(:locales, Locale)
    has_many(:translation_keys, TranslationKey)

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
  def remove_changeset(project, attrs) do
    project
    |> cast(attrs, [:is_removed, :removed_at])
    |> validate_required([:is_removed, :removed_at])
  end
end
