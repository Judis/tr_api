defmodule I18NAPI.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field(:is_removed, :boolean, default: false)
    field(:name, :string)
    field(:removed_at, :naive_datetime)

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :is_removed, :removed_at])
    |> validate_required([:name, :is_removed, :removed_at])
  end
end
