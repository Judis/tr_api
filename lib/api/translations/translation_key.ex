defmodule I18NAPI.Translations.TranslationKey do
  use Ecto.Schema
  import Ecto.Changeset

  schema "translation_keys" do
    field(:context, :string)
    field(:is_removed, :boolean, default: false)
    field(:key, :string)
    field(:removed_at, :naive_datetime)
    field(:status, :integer)

    belongs_to(:project, I18NAPI.Projects.Project)

    timestamps()
  end

  @doc false
  def changeset(translation_key, attrs) do
    translation_key
    |> cast(attrs, [:key, :context, :status, :is_removed, :removed_at, :project_id])
    |> validate_required([:key])
    |> unique_constraint(:key, name: :translation_keys_project_id_key_is_removed_index)
  end
end
