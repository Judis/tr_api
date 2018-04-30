defmodule I18NAPI.TranslationsTest do
  use I18NAPI.DataCase

  alias I18NAPI.Translations

  describe "locales" do
    alias I18NAPI.Translations.Locale

    @valid_attrs %{
      count_of_keys: 42,
      count_of_translated_keys: 42,
      count_of_words: 42,
      is_default: true,
      is_removed: true,
      locale: "some locale",
      removed_at: ~N[2010-04-17 14:00:00.000000]
    }
    @update_attrs %{
      count_of_keys: 43,
      count_of_translated_keys: 43,
      count_of_words: 43,
      is_default: false,
      is_removed: false,
      locale: "some updated locale",
      removed_at: ~N[2011-05-18 15:01:01.000000]
    }
    @invalid_attrs %{
      count_of_keys: nil,
      count_of_translated_keys: nil,
      count_of_words: nil,
      is_default: nil,
      is_removed: nil,
      locale: nil,
      removed_at: nil
    }

    def locale_fixture(attrs \\ %{}) do
      {:ok, locale} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Translations.create_locale()

      locale
    end

    test "list_locales/0 returns all locales" do
      locale = locale_fixture()
      assert Translations.list_locales() == [locale]
    end

    test "get_locale!/1 returns the locale with given id" do
      locale = locale_fixture()
      assert Translations.get_locale!(locale.id) == locale
    end

    test "create_locale/1 with valid data creates a locale" do
      assert {:ok, %Locale{} = locale} = Translations.create_locale(@valid_attrs)
      assert locale.count_of_keys == 42
      assert locale.count_of_translated_keys == 42
      assert locale.count_of_words == 42
      assert locale.is_default == true
      assert locale.is_removed == true
      assert locale.locale == "some locale"
      assert locale.removed_at == ~N[2010-04-17 14:00:00.000000]
    end

    test "create_locale/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Translations.create_locale(@invalid_attrs)
    end

    test "update_locale/2 with valid data updates the locale" do
      locale = locale_fixture()
      assert {:ok, locale} = Translations.update_locale(locale, @update_attrs)
      assert %Locale{} = locale
      assert locale.count_of_keys == 43
      assert locale.count_of_translated_keys == 43
      assert locale.count_of_words == 43
      assert locale.is_default == false
      assert locale.is_removed == false
      assert locale.locale == "some updated locale"
      assert locale.removed_at == ~N[2011-05-18 15:01:01.000000]
    end

    test "update_locale/2 with invalid data returns error changeset" do
      locale = locale_fixture()
      assert {:error, %Ecto.Changeset{}} = Translations.update_locale(locale, @invalid_attrs)
      assert locale == Translations.get_locale!(locale.id)
    end

    test "delete_locale/1 deletes the locale" do
      locale = locale_fixture()
      assert {:ok, %Locale{}} = Translations.delete_locale(locale)
      assert_raise Ecto.NoResultsError, fn -> Translations.get_locale!(locale.id) end
    end

    test "change_locale/1 returns a locale changeset" do
      locale = locale_fixture()
      assert %Ecto.Changeset{} = Translations.change_locale(locale)
    end
  end

  describe "translation_keys" do
    alias I18NAPI.Translations.TranslationKey

    @valid_attrs %{
      context: "some context",
      is_removed: true,
      key: "some key",
      removed_at: ~N[2010-04-17 14:00:00.000000],
      status: 42,
      value: "some value"
    }
    @update_attrs %{
      context: "some updated context",
      is_removed: false,
      key: "some updated key",
      removed_at: ~N[2011-05-18 15:01:01.000000],
      status: 43,
      value: "some updated value"
    }
    @invalid_attrs %{
      context: nil,
      is_removed: nil,
      key: nil,
      removed_at: nil,
      status: nil,
      value: nil
    }

    def translation_key_fixture(attrs \\ %{}) do
      {:ok, translation_key} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Translations.create_translation_key()

      translation_key
    end

    test "list_translation_keys/0 returns all translation_keys" do
      translation_key = translation_key_fixture()
      assert Translations.list_translation_keys() == [translation_key]
    end

    test "get_translation_key!/1 returns the translation_key with given id" do
      translation_key = translation_key_fixture()
      assert Translations.get_translation_key!(translation_key.id) == translation_key
    end

    test "create_translation_key/1 with valid data creates a translation_key" do
      assert {:ok, %TranslationKey{} = translation_key} =
               Translations.create_translation_key(@valid_attrs)

      assert translation_key.context == "some context"
      assert translation_key.is_removed == true
      assert translation_key.key == "some key"
      assert translation_key.removed_at == ~N[2010-04-17 14:00:00.000000]
      assert translation_key.status == 42
      assert translation_key.value == "some value"
    end

    test "create_translation_key/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Translations.create_translation_key(@invalid_attrs)
    end

    test "update_translation_key/2 with valid data updates the translation_key" do
      translation_key = translation_key_fixture()

      assert {:ok, translation_key} =
               Translations.update_translation_key(translation_key, @update_attrs)

      assert %TranslationKey{} = translation_key
      assert translation_key.context == "some updated context"
      assert translation_key.is_removed == false
      assert translation_key.key == "some updated key"
      assert translation_key.removed_at == ~N[2011-05-18 15:01:01.000000]
      assert translation_key.status == 43
      assert translation_key.value == "some updated value"
    end

    test "update_translation_key/2 with invalid data returns error changeset" do
      translation_key = translation_key_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Translations.update_translation_key(translation_key, @invalid_attrs)

      assert translation_key == Translations.get_translation_key!(translation_key.id)
    end

    test "delete_translation_key/1 deletes the translation_key" do
      translation_key = translation_key_fixture()
      assert {:ok, %TranslationKey{}} = Translations.delete_translation_key(translation_key)

      assert_raise Ecto.NoResultsError, fn ->
        Translations.get_translation_key!(translation_key.id)
      end
    end

    test "change_translation_key/1 returns a translation_key changeset" do
      translation_key = translation_key_fixture()
      assert %Ecto.Changeset{} = Translations.change_translation_key(translation_key)
    end
  end

  describe "translations" do
    alias I18NAPI.Translations.Translation

    @valid_attrs %{
      is_removed: true,
      removed_at: ~N[2010-04-17 14:00:00.000000],
      value: "some value"
    }
    @update_attrs %{
      is_removed: false,
      removed_at: ~N[2011-05-18 15:01:01.000000],
      value: "some updated value"
    }
    @invalid_attrs %{is_removed: nil, removed_at: nil, value: nil}

    def translation_fixture(attrs \\ %{}) do
      {:ok, translation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Translations.create_translation()

      translation
    end

    test "list_translations/0 returns all translations" do
      translation = translation_fixture()
      assert Translations.list_translations() == [translation]
    end

    test "get_translation!/1 returns the translation with given id" do
      translation = translation_fixture()
      assert Translations.get_translation!(translation.id) == translation
    end

    test "create_translation/1 with valid data creates a translation" do
      assert {:ok, %Translation{} = translation} = Translations.create_translation(@valid_attrs)
      assert translation.is_removed == true
      assert translation.removed_at == ~N[2010-04-17 14:00:00.000000]
      assert translation.value == "some value"
    end

    test "create_translation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Translations.create_translation(@invalid_attrs)
    end

    test "update_translation/2 with valid data updates the translation" do
      translation = translation_fixture()
      assert {:ok, translation} = Translations.update_translation(translation, @update_attrs)
      assert %Translation{} = translation
      assert translation.is_removed == false
      assert translation.removed_at == ~N[2011-05-18 15:01:01.000000]
      assert translation.value == "some updated value"
    end

    test "update_translation/2 with invalid data returns error changeset" do
      translation = translation_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Translations.update_translation(translation, @invalid_attrs)

      assert translation == Translations.get_translation!(translation.id)
    end

    test "delete_translation/1 deletes the translation" do
      translation = translation_fixture()
      assert {:ok, %Translation{}} = Translations.delete_translation(translation)
      assert_raise Ecto.NoResultsError, fn -> Translations.get_translation!(translation.id) end
    end

    test "change_translation/1 returns a translation changeset" do
      translation = translation_fixture()
      assert %Ecto.Changeset{} = Translations.change_translation(translation)
    end
  end
end
