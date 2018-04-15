defmodule I18NAPI.Projects.UserLocales do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_locales" do
    field(:role, :integer)
    field(:user_id, :id)
    field(:locale_id, :id)

    timestamps()
  end

  @doc false
  def changeset(user_locales, attrs) do
    user_locales
    |> cast(attrs, [:role])
    |> validate_required([:role])
  end
end
