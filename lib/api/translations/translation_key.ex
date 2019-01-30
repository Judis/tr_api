defmodule I18NAPI.Translations.TranslationKey do
  use Ecto.Schema
  import Ecto.Changeset
  alias I18NAPI.Utilities

  schema "translation_keys" do
    field(:context, :string)
    field(:is_removed, :boolean, default: false)
    field(:key, :string)
    field(:removed_at, :naive_datetime)
    field(:default_value, :string, virtual: true)

    belongs_to(:project, I18NAPI.Projects.Project)
    has_many(:translations, I18NAPI.Translations.Translation)

    timestamps()
  end

  @doc false
  def changeset(translation_key, attrs) do
    translation_key
    |> cast(attrs, [
      :key,
      :default_value,
      :context,
      :is_removed,
      :removed_at,
      :project_id
    ])
    |> validate_required([
      :key,
      :default_value,
      :project_id
    ])
    |> unique_constraint(:key, name: :translation_keys_project_id_key_is_removed_index)
  end

  @doc false
  def update_changeset(translation_key, attrs) do
    translation_key
    |> cast(attrs, [
      :key,
      :default_value,
      :context,
      :is_removed,
      :removed_at,
      :project_id
    ])
    |> validate_required([:key])
    |> unique_constraint(:key, name: :translation_keys_project_id_key_is_removed_index)
  end

  @doc false
  def remove_changeset(translation_key) do
    translation_key
    |> cast(%{is_removed: true, removed_at: Utilities.get_utc_now()}, [:is_removed, :removed_at])
  end

  @doc false
  def restore_changeset(translation_key) do
    translation_key
    |> cast(%{is_removed: false, removed_at: nil}, [:is_removed, :removed_at])
  end
end
