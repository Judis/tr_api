defmodule I18NAPI.TranslationsTest do
  use ExUnit.Case, async: false
  @moduletag :translations_api

  use I18NAPI.DataCase
  alias I18NAPI.Translations
  alias I18NAPI.Projects
  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(I18NAPI.Repo, ownership_timeout: 30_000)
    Ecto.Adapters.SQL.Sandbox.mode(I18NAPI.Repo, {:shared, self()})
    :ok
  end

  @user_attrs %{
    name: "test name",
    email: "test@email.test",
    password: "Qw!23456",
    password_confirmation: "Qw!23456",
    source: "test source"
  }

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@user_attrs)
      |> Accounts.create_user()

    user
  end

  @valid_project_attrs %{
    name: "some name",
    default_locale: "en"
  }

  def project_fixture(attrs \\ %{}, %User{} = user) do
    {:ok, project} =
      attrs
      |> Enum.into(@valid_project_attrs)
      |> Projects.create_project(user)

    project
  end

  @valid_locale_attrs %{
    locale: "some locale",
    status: 0,
    is_default: true
  }

  describe "locales" do
    alias I18NAPI.Translations.Locale

    @update_locale_attrs %{
      locale: "some updated locale",
      status: 1,
      is_default: false
    }
    @invalid_locale_attrs %{
      locale: nil,
      status: nil,
      is_default: nil
    }

    def locale_fixture(attrs \\ %{}, project_id \\ nil) do
      project_id =
        unless is_integer(project_id) do
          project_fixture(@valid_project_attrs, user_fixture()).id
        else
          project_id
        end

      {:ok, locale} =
        attrs
        |> Enum.into(@valid_locale_attrs)
        |> Translations.create_locale(project_id)

      locale
    end

    test "list_locales/0 returns all locales" do
      locale = locale_fixture()
      assert Enum.member?(Translations.list_locales(), locale)
    end

    test "get_locale!/1 returns the locale with given id" do
      locale = locale_fixture()
      assert Translations.get_locale!(locale.id) == locale
    end

    test "create_locale/1 with valid data creates a locale" do
      user = user_fixture()
      project_id = project_fixture(@valid_project_attrs, user).id

      assert {:ok, %Locale{} = locale} =
               Translations.create_locale(@valid_locale_attrs, project_id)

      assert locale.is_default == true
      assert locale.locale == "some locale"
    end

    test "create_locale/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Translations.create_locale(@invalid_locale_attrs, nil)
    end

    test "update_locale/2 with valid data updates the locale" do
      locale = locale_fixture()
      assert {:ok, locale} = Translations.update_locale(locale, @update_locale_attrs)
      assert %Locale{} = locale
      assert locale.is_default == false
      assert locale.locale == "some updated locale"
    end

    test "update_locale/2 with set non default locale to default" do
      project_id = project_fixture(@valid_project_attrs, user_fixture()).id
      first_locale = locale_fixture(@valid_locale_attrs, project_id)
      second_locale = locale_fixture(@update_locale_attrs, project_id)
      assert first_locale.is_default
      assert second_locale.is_default == false

      assert {:ok, second_locale} = Translations.update_locale(second_locale, %{is_default: true})
      assert first_locale = Translations.get_locale!(first_locale.id)

      assert first_locale.is_default == false
      assert second_locale.is_default
    end

    test "update_locale/2 with invalid data returns error changeset" do
      locale = locale_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Translations.update_locale(locale, @invalid_locale_attrs)

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

  @valid_translation_key_attrs %{
    context: "some context",
    is_removed: false,
    key: "some key",
    default_value: "some value"
  }

  describe "translation_keys" do
    alias I18NAPI.Translations.TranslationKey

    @update_translation_key_attrs %{
      context: "some updated context",
      is_removed: true,
      key: "some updated key",
      default_value: "some updated value"
    }
    @invalid_translation_key_attrs %{
      context: nil,
      is_removed: nil,
      key: nil,
      removed_at: nil,
      default_value: nil
    }

    def translation_key_fixture(attrs \\ %{}, project_id \\ nil) do
      project_id =
        unless is_integer(project_id) do
          project_fixture(@valid_project_attrs, user_fixture()).id
        else
          project_id
        end

      attrs = Enum.into(attrs, @valid_translation_key_attrs)

      {:ok, translation_key} =
        attrs
        |> Translations.create_translation_key(project_id)

      translation_key
    end

    test "list_translation_keys/0 returns all translation_keys" do
      translation_key_fixture()
      assert [%TranslationKey{} = translation_key] = Translations.list_translation_keys()
    end

    test "get_translation_key!/1 returns the translation_key with given id" do
      translation_key = translation_key_fixture()
      assert Translations.get_translation_key!(translation_key.id) == translation_key
    end

    test "create_translation_key/1 with valid data creates a translation_key" do
      user = user_fixture()
      project_id = project_fixture(@valid_project_attrs, user).id

      {:ok, %TranslationKey{} = translation_key} =
        Translations.create_translation_key(@valid_translation_key_attrs, project_id)

      assert translation_key.context == @valid_translation_key_attrs.context
      assert translation_key.is_removed == @valid_translation_key_attrs.is_removed
      assert translation_key.key == @valid_translation_key_attrs.key
      assert translation_key.default_value == @valid_translation_key_attrs.default_value
    end

    test "create_translation_key/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Translations.create_translation_key(@invalid_translation_key_attrs)
    end

    test "update_translation_key/2 with valid data updates the translation_key" do
      assert {:ok, t_key} =
               Translations.update_translation_key(
                 translation_key_fixture(),
                 @update_translation_key_attrs
               )

      assert translation_key = Translations.get_translation_key!(t_key.id)
      assert translation_key.context == @update_translation_key_attrs.context
      assert translation_key.is_removed == @update_translation_key_attrs.is_removed
      assert translation_key.key == @update_translation_key_attrs.key
      assert translation_key.default_value == @update_translation_key_attrs.default_value
    end

    test "update_translation_key/2 with invalid data returns error changeset" do
      translation_key = translation_key_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Translations.update_translation_key(
                 translation_key,
                 @invalid_translation_key_attrs
               )

      assert translation_key == Translations.get_translation_key!(translation_key.id)
    end

    test "delete_translation_key/1 deletes the translation_key" do
      assert {:ok, t_key} = Translations.delete_translation_key(translation_key_fixture())

      assert translation_key = Translations.get_translation_key!(t_key.id)
      assert translation_key.is_removed == true
    end

    test "change_translation_key/1 returns a translation_key changeset" do
      translation_key = translation_key_fixture()
      assert %Ecto.Changeset{} = Translations.change_translation_key(translation_key)
    end
  end

  describe "translations" do
    alias I18NAPI.Translations.Translation
    alias I18NAPI.Translations.TranslationKey

    @valid_translation_attrs %{
      value: "some translation value",
      status: :verified
    }
    @update_translation_attrs %{
      value: "some updated value",
      status: :unverified
    }
    @invalid_translation_attrs %{value: nil, status: nil}

    def translation_fixture(attrs, project_id) do
      project_id =
        unless is_integer(project_id) do
          project_fixture(@valid_project_attrs, user_fixture()).id
        else
          project_id
        end

      translation_key_id =
        translation_key_fixture(
          %{
            context: "some context",
            is_removed: false,
            key: "some key",
            default_value: "some value"
          },
          project_id
        ).id

      locale_id = locale_fixture(@valid_locale_attrs, project_id).id

      attrs =
        %{translation_key_id: translation_key_id}
        |> Enum.into(attrs)

      {:ok, translation} =
        Translations.get_translation(translation_key_id, locale_id)
        |> Translations.update_translation(attrs)

      translation
    end

    test "list_translations/0 returns all translations" do
      user = user_fixture()
      project_id = project_fixture(@valid_project_attrs, user).id
      translation = translation_fixture(@valid_translation_attrs, project_id)

      assert Enum.member?(Translations.list_translations(), translation)
    end

    test "get_translation!/1 returns the translation with given id" do
      user = user_fixture()
      project_id = project_fixture(@valid_project_attrs, user).id
      translation = translation_fixture(@valid_translation_attrs, project_id)

      assert Translations.get_translation!(translation.id) == translation
    end

    test "create_translation/1 with valid data creates a translation" do
      project_id = project_fixture(@valid_project_attrs, user_fixture()).id
      translation_key = translation_key_fixture(@valid_translation_key_attrs, project_id)
      locale_id = locale_fixture(@valid_locale_attrs, project_id).id

      attrs = Map.put(@valid_translation_attrs, :translation_key_id, translation_key.id)

      assert {:ok, %Translation{} = translation} =
               Translations.get_translation(translation_key.id, locale_id)
               |> Translations.update_translation(attrs)

      assert translation.value == @valid_translation_attrs.value
    end

    @valid_not_default_locale_attrs %{
      locale: "not default locale",
      status: 0,
      is_default: false
    }
    @valid_alternative_not_default_locale_attrs %{
      locale: "alternative not default locale",
      status: 0,
      is_default: false
    }
    @valid_alternative_translation_attrs %{
      value: "alternative translation value",
      status: :verified
    }

    test "update_translation/2 with valid data updates the translation in not default locale" do
      project_id = project_fixture(@valid_project_attrs, user_fixture()).id
      # ^^^ created default locale for project
      translation_key = translation_key_fixture(@valid_translation_key_attrs, project_id)
      # ^^^ created default translation for key
      locale = locale_fixture(@valid_not_default_locale_attrs, project_id)
      attrs = Map.put(@valid_translation_attrs, :translation_key_id, translation_key.id)

      {:ok, %Translation{} = translation} =
        Translations.get_translation(translation_key.id, locale.id)
        |> Translations.update_translation(attrs)

      alter_locale_id = locale_fixture(@valid_alternative_not_default_locale_attrs, project_id).id

      alter_attrs =
        Map.put(@valid_alternative_translation_attrs, :translation_key_id, translation_key.id)

      {:ok, %Translation{} = alternative_translation} =
        Translations.get_translation(translation_key.id, alter_locale_id)
        |> Translations.update_translation(alter_attrs)

      assert alternative_translation.status == @valid_alternative_translation_attrs.status

      assert {:ok, updated_translation} =
               Translations.update_translation(translation, @update_translation_attrs)

      assert %Translation{} = updated_translation
      assert updated_translation.value == @update_translation_attrs.value
      assert updated_translation.status == @update_translation_attrs.status
      assert alternative_translation.status == @valid_alternative_translation_attrs.status
    end

    test "update_translation/2 with valid data updates the translation in default locale" do
      project_id = project_fixture(@valid_project_attrs, user_fixture()).id

      {:ok, translation_key} =
        Translations.create_translation_key(@valid_translation_key_attrs, project_id)

      translation = Translations.get_default_translation(translation_key.id)

      assert Translations.get_locale!(translation.locale_id).is_default == true

      {:ok, alter_locale} =
        Translations.create_locale(@valid_alternative_not_default_locale_attrs, project_id)

      {:ok, %Translation{} = alternative_translation} =
        Translations.get_translation(translation_key.id, alter_locale.id)
        |> Translations.update_translation(
          Map.put(@valid_alternative_translation_attrs, :translation_key_id, translation_key.id)
        )

      assert Translations.get_locale!(alternative_translation.locale_id).is_default == false

      assert alternative_translation.status == @valid_alternative_translation_attrs.status

      assert {:ok, updated_translation} =
               Translations.update_translation(translation, @update_translation_attrs)

      assert %Translation{} = updated_translation
      assert updated_translation.value == @update_translation_attrs.value
      assert updated_translation.status == @update_translation_attrs.status
      # ----------------------------------------------------
      alternative_translation = Translations.get_translation!(alternative_translation.id)
      assert alternative_translation.status == :unverified
    end

    test "update_translation/2 with invalid data returns error changeset" do
      user = user_fixture()
      project_id = project_fixture(@valid_project_attrs, user).id
      translation = translation_fixture(@valid_translation_attrs, project_id)

      assert {:error, %Ecto.Changeset{}} =
               Translations.update_translation(translation, @invalid_translation_attrs)

      assert translation == Translations.get_translation!(translation.id)
    end

    test "update_translation/2 with valid with unused parameter data updates the translation" do
      project_id = project_fixture(@valid_project_attrs, user_fixture()).id
      translation = translation_fixture(@valid_translation_attrs, project_id)

      attrs =
        @update_translation_attrs
        |> Enum.into(%{locale_id: translation.locale_id - 1})

      assert {:ok, translation} = Translations.update_translation(translation, attrs)
      assert %Translation{} = translation
      assert translation.value == @update_translation_attrs.value
    end

    test "delete_translation/1 deletes the translation" do
      user = user_fixture()
      project_id = project_fixture(@valid_project_attrs, user).id
      translation = translation_fixture(@valid_translation_attrs, project_id)

      assert {:ok, %Translation{}} = Translations.delete_translation(translation)
      assert_raise Ecto.NoResultsError, fn -> Translations.get_translation!(translation.id) end
    end

    test "change_translation/1 returns a translation changeset" do
      user = user_fixture()
      project_id = project_fixture(@valid_project_attrs, user).id
      translation = translation_fixture(@valid_translation_attrs, project_id)

      assert %Ecto.Changeset{} = Translations.change_translation(translation)
    end
  end
end
