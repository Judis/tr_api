defmodule I18NAPI.Translations.UserLocale do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_locales" do
    field(:role, :integer)
    field(:user_id, :id)
    field(:locale_id, :id)

    timestamps()
  end

  @doc false
  def create_changeset(user_locales, attrs) do
    user_locales
    |> cast(attrs, [:user_id, :locale_id, :role])
    |> validate_required([:role])
  end

  @doc false
  def update_changeset(user_locales, attrs) do
    user_locales
    |> cast(attrs, [:role])
    |> validate_required([:role])
  end
end
