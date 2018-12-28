defmodule I18NAPI.StatisticsWorkerTest do
  use ExUnit.Case, async: true
  @moduletag :statistics_watcher_api

  use I18NAPI.DataCase
  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User
  alias I18NAPI.Projects
  alias I18NAPI.Translations
  alias I18NAPI.Translations.Statistics
  alias I18NAPI.Translations.StatisticsWatcher

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

  def locale_fixture(attrs \\ %{}, project_id) do
    {:ok, locale} =
      attrs
      |> Enum.into(@valid_locale_attrs)
      |> Translations.create_locale(project_id)

    locale
  end

  @valid_translation_key_attrs %{
    context: "some context",
    is_removed: false,
    key: "some key",
    default_value: "some value"
  }

  @alter_translation_key_attrs %{
    context: "alter context",
    is_removed: false,
    key: "alter key",
    default_value: "alter value"
  }

  def translation_key_fixture(attrs \\ %{}, project_id \\ nil) do
    {:ok, translation_key} =
      attrs
      |> Translations.create_translation_key(project_id)

    translation_key
  end

  def translation_fixture(attrs, locale_id, translation_key_id) do
    attrs =
      %{translation_key_id: translation_key_id}
      |> Enum.into(attrs)

    {:ok, translation} = Translations.create_translation(attrs, locale_id)

    translation
  end

  setup do
    supervisor_pid = GenServer.whereis(:statistics_supervisor)
    {:ok, server: supervisor_pid}
  end

  describe "init" do
    test "start StatisticsSupervisor", %{server: pid} do
      assert pid == GenServer.whereis(:statistics_supervisor)
    end

    test "start StatisticsWatcher" do
      assert GenServer.whereis(:statistics_watcher)
    end
  end

  describe "callbacks" do
    test "add & get test" do
      StatisticsWatcher.add_project(1)
      StatisticsWatcher.add_project(2)
      StatisticsWatcher.add_locale({3, 1})
      StatisticsWatcher.add_locale({2, 1})
      StatisticsWatcher.add_locale({3, 1})

      fixture_projects =
        MapSet.new()
        |> MapSet.put(1)
        |> MapSet.put(2)

      fixture_locales =
        MapSet.new()
        |> MapSet.put({3, 1})
        |> MapSet.put({2, 1})

      {projects, locales} = StatisticsWatcher.get()
      assert MapSet.equal?(fixture_locales, locales)
      assert MapSet.equal?(fixture_projects, projects)
      {projects, locales} = StatisticsWatcher.get()
      assert MapSet.equal?(fixture_locales, locales)
      assert MapSet.equal?(fixture_projects, projects)
    end

    test "add & flush test" do
      StatisticsWatcher.add_project(1)
      StatisticsWatcher.add_project(2)
      StatisticsWatcher.add_locale({3, 1})
      StatisticsWatcher.add_locale({2, 1})
      StatisticsWatcher.add_locale({3, 1})

      fixture_projects =
        MapSet.new()
        |> MapSet.put(1)
        |> MapSet.put(2)

      fixture_locales =
        MapSet.new()
        |> MapSet.put({3, 1})
        |> MapSet.put({2, 1})

      {projects, locales} = StatisticsWatcher.flush()
      assert MapSet.equal?(fixture_locales, locales)
      assert MapSet.equal?(fixture_projects, projects)
      {projects, locales} = StatisticsWatcher.flush()
      assert MapSet.to_list(locales) == []
      assert MapSet.to_list(projects) == []
    end
  end

  describe "recalculate" do
    test "a" do
      project = project_fixture(@valid_project_attrs, user_fixture())
    end
  end
end
