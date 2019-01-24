defmodule I18NAPI.Translations.UserLocale do
  use Ecto.Schema
  import Ecto.Changeset
  alias I18NAPI.Utilities

  schema "user_locales" do
    field(:role, :integer)
    field(:user_id, :id)
    field(:locale_id, :id)
    field(:is_removed, :boolean, default: false)
    field(:removed_at, :naive_datetime)

    timestamps()
  end

  @doc false
  def create_changeset(user_locale, attrs) do
    user_locale
    |> cast(attrs, [:user_id, :locale_id, :role])
    |> validate_required([:role])
  end

  @doc false
  def update_changeset(user_locale, attrs) do
    user_locale
    |> cast(attrs, [:role])
    |> validate_required([:role])
  end

  @doc false
  def remove_changeset(user_locale) do
    user_locale
    |> cast(%{is_removed: true, removed_at: Utilities.get_utc_now()}, [:is_removed, :removed_at])
    |> validate_required([:is_removed, :removed_at])
  end
end
