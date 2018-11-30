defmodule I18NAPI.StatisticsTest do
  use ExUnit.Case, async: true
  @moduletag :statistics_api

  use I18NAPI.DataCase
  alias I18NAPI.Translations
  alias I18NAPI.Translations.Statistics
  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User
  alias I18NAPI.Projects
  alias I18NAPI.Projects.Project

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(I18NAPI.Repo)
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

  describe "total_count_of_translation_keys" do
    test "update_total_count_of_translation_keys/2 with increment operation" do
      project = project_fixture(%{}, user_fixture())
      assert project.total_count_of_translation_keys == 0

      Task.await(
        Statistics.update_total_count_of_translation_keys(project.id, :inc)
      )

      project = Projects.get_project!(project.id)
      assert project.total_count_of_translation_keys == 1
    end

    test "update_total_count_of_translation_keys/2 with decrement operation" do
      project = project_fixture(%{}, user_fixture())
      assert project.total_count_of_translation_keys == 0

      Task.await(
        Statistics.update_total_count_of_translation_keys(project.id, :inc)
      )
      Task.await(
        Statistics.update_total_count_of_translation_keys(project.id, :dec)
      )

      project = Projects.get_project!(project.id)
      assert project.total_count_of_translation_keys == 0
    end

  end

  describe "count_of_keys_at_locales" do
    @valid_locale_attrs %{
      locale: "some locale",
      status: 0,
      is_default: true
    }

    def locale_fixture(attrs \\ %{}, project_id) do
      {:ok, locale} =
        attrs
        |> Enum.into(@valid_locale_attrs)
        |> Translations.create_locale(project_id)

      locale
    end

    test "recalculate_count_of_untranslated_keys_at_locales/1 when " do
      project = project_fixture(%{}, user_fixture())
      Task.await(
        Statistics.update_total_count_of_translation_keys(project.id, :inc, 5)
      )
      locale = locale_fixture(project.id)

      Task.await(
        Statistics.update_count_of_keys_at_locales(locale.id, :inc, :translated, 3)
      )
      assert locale.count_of_untranslated_keys == 0

      Task.await(
        Statistics.recalculate_count_of_untranslated_keys_at_locales(project.id)
      )
      locale = Translations.get_locale!(locale.id)
      assert locale.count_of_untranslated_keys == 2
    end

    test "update_count_of_keys_at_locales/3 increment and decrement for :count_of_translated_keys" do
      project = project_fixture(%{}, user_fixture())
      locale = locale_fixture(project.id)

      assert locale.count_of_translated_keys == 0
      Task.await(
        Statistics.update_count_of_keys_at_locales(locale.id, :inc, :translated)
      )

      locale = Translations.get_locale!(locale.id)
      assert locale.count_of_translated_keys == 1

      Task.await(
        Statistics.update_count_of_keys_at_locales(locale.id, :dec, :translated)
      )

      locale = Translations.get_locale!(locale.id)
      assert locale.count_of_translated_keys == 0
    end

    test "update_count_of_keys_at_locales/4 increment and decrement for :count_of_translated_keys" do
      project = project_fixture(%{}, user_fixture())
      locale = locale_fixture(project.id)

      assert locale.count_of_translated_keys == 0
      Task.await(
        Statistics.update_count_of_keys_at_locales(locale.id, :inc, :translated, 4)
      )

      locale = Translations.get_locale!(locale.id)
      assert locale.count_of_translated_keys == 4
      Task.await(
        Statistics.update_count_of_keys_at_locales(locale.id, :dec, :translated, 2)
      )

      locale = Translations.get_locale!(locale.id)
      assert locale.count_of_translated_keys == 2
    end

    test "update_count_of_keys_at_locales/4 increment and decrement for :count_of_verified_keys" do
      project = project_fixture(%{}, user_fixture())
      locale = locale_fixture(project.id)

      assert locale.count_of_verified_keys == 0
      Task.await(
        Statistics.update_count_of_keys_at_locales(locale.id, :inc, :verified, 4)
      )

      locale = Translations.get_locale!(locale.id)
      assert locale.count_of_verified_keys == 4
      Task.await(
        Statistics.update_count_of_keys_at_locales(locale.id, :dec, :verified, 2)
      )

      locale = Translations.get_locale!(locale.id)
      assert locale.count_of_verified_keys == 2
    end

    test "update_count_of_keys_at_locales/4 increment and decrement for :count_of_not_verified_keys" do
      project = project_fixture(%{}, user_fixture())
      locale = locale_fixture(project.id)

      assert locale.count_of_not_verified_keys == 0
      Task.await(
        Statistics.update_count_of_keys_at_locales(locale.id, :inc, :not_verified, 4)
      )

      locale = Translations.get_locale!(locale.id)
      assert locale.count_of_not_verified_keys == 4
      Task.await(
        Statistics.update_count_of_keys_at_locales(locale.id, :dec, :not_verified, 2)
      )

      locale = Translations.get_locale!(locale.id)
      assert locale.count_of_not_verified_keys == 2
    end

    test "update_count_of_keys_at_locales/4 increment and decrement for :count_of_keys_need_check" do
      project = project_fixture(%{}, user_fixture())
      locale = locale_fixture(project.id)

      assert locale.count_of_keys_need_check == 0
      Task.await(
        Statistics.update_count_of_keys_at_locales(locale.id, :inc, :need_check, 4)
      )

      locale = Translations.get_locale!(locale.id)
      assert locale.count_of_keys_need_check == 4
      Task.await(
        Statistics.update_count_of_keys_at_locales(locale.id, :dec, :need_check, 2)
      )

      locale = Translations.get_locale!(locale.id)
      assert locale.count_of_keys_need_check == 2
    end

  end

end
