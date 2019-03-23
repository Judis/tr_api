defmodule I18NAPI.Translations.ImportTest do
  use ExUnit.Case, async: false
  @moduletag :locale_import_api

  use I18NAPIWeb.ConnCase
  use I18NAPI.Fixtures, [:setup, :user, :project, :locale, :translation_key, :import_locale]

  alias I18NAPI.Translations
  alias I18NAPI.Translations.{Import, TranslationKey}

  describe "import locale" do
    setup [:project, :locale, :translation_key]

    test "create_new_translation_key_if_not_exists pass if exists",
         %{translation_key: translation_key} do
      t_k = translation_key |> Import.create_new_translation_key_if_not_exists(%{})
      assert translation_key.id == t_k.id
    end

    test "create_new_translation_key_if_not_exists create if not exists", %{project: project} do
      assert %TranslationKey{} =
               nil
               |> Import.create_new_translation_key_if_not_exists(
                 attrs(:translation_key)
                 |> Map.put(:project_id, project.id)
               )
    end

    test "process_translation_key get if exists with equal value", %{locale: locale} do
      translation_key = fixture(:translation_key, %{project_id: locale.project_id})

      {t_k, _, _} =
        Import.process_translation_key(
          {attrs(:translation_key).key, attrs(:translation_key).default_value, locale}
        )

      assert translation_key.id == t_k.id
      assert translation_key.key == t_k.key
    end

    test "process_translation_key create new if not exists", %{locale: locale} do
      {t_k, _, _} =
        Import.process_translation_key({
          attrs(:translation_key).key,
          attrs(:translation_key).default_value,
          locale
        })

      assert %TranslationKey{} = t_k
    end

    test "import_locale to  empty locale", %{locale: locale} do
      assert {:ok, _} = Import.import_locale(locale.id, {:ok, attrs(:import_locale_valid)})
      t_k_id = Translations.get_translation_key_by_key("a_key", locale.project_id).id

      assert attrs(:import_locale_valid)["a_key"] ==
               Translations.get_translation(t_k_id, locale.id).value
    end

    test "import_locale to not empty locale", %{locale: locale} do
      fixture(:translation_key, %{
        project_id: locale.project_id,
        key: "a_key",
        default_value: "a_default_value"
      })

      assert {:ok, _} = Import.import_locale(locale.id, {:ok, attrs(:import_locale_valid)})
      t_k_id = Translations.get_translation_key_by_key("a_key", locale.project_id).id

      assert attrs(:import_locale_valid)["a_key"] ==
               Translations.get_translation(t_k_id, locale.id).value
    end

    test "import_locale with unknown_locale" do
      assert {:error, :unknown_locale} =
               Import.import_locale(0, {:ok, attrs(:import_locale_valid)})
    end

    test "process_translation pass if valid", %{locale: locale} do
      fixture_t_k =
        fixture(:translation_key, %{
          project_id: locale.project_id,
          key: "a_key",
          default_value: "a_default_value"
        })

      assert {:ok, _} = Import.process_translation({fixture_t_k, "a_value", locale})
    end

    test "process_translation create translation if not valid", %{locale: locale} do
      fixture_t_k =
        fixture(:translation_key, %{
          project_id: locale.project_id,
          key: "a_key",
          default_value: "a_default_value"
        })

      assert {:error, _} = Import.process_translation({fixture_t_k, "a_value", 0})
    end
  end

  defp project(%{}) do
    {:ok, project: fixture(:project, %{user: fixture(:user)})}
  end

  defp locale(%{}) do
    {:ok, locale: fixture(:locale, %{project_id: fixture(:project, user: fixture(:user)).id})}
  end

  defp translation_key(%{}) do
    {:ok,
     translation_key:
       fixture(:translation_key, %{project_id: fixture(:project, %{user: fixture(:user)}).id})}
  end
end
