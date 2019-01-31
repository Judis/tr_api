defmodule I18NAPI.Translations.ExportTest do
  use ExUnit.Case, async: false
  @moduletag :locale_export_api

  use I18NAPIWeb.ConnCase
  use I18NAPI.Fixtures, [:setup, :user, :project, :locale]

  alias I18NAPI.Translations
  alias I18NAPI.Translations.{Export, TranslationKey}

  describe "export locale" do
    setup [:locale]

    test "as flat JSON", %{locale: locale} do
      assert {:ok, "{}", "json"} = Export.export_locale(locale.id, "json_flat")
    end

  end

  defp locale(%{}) do
    {:ok, locale: fixture(:locale, %{project_id: fixture(:project, user: fixture(:user)).id})}
  end
end
