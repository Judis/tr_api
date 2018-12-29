defmodule I18NAPI.ProjectsTest do
  use ExUnit.Case, async: true
  @moduletag :project_api

  use I18NAPI.DataCase
  alias I18NAPI.Projects
  alias I18NAPI.Projects.Project
  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User

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

  describe "projects" do
    @update_project_attrs %{
      name: "some updated name"
    }

    @invalid_project_attrs %{name: nil, default_locale: nil, is_removed: nil, removed_at: nil}

    test "list_projects/0 returns all projects" do
      project = project_fixture(%{}, user_fixture())
      assert Projects.list_projects() == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture(%{}, user_fixture())
      assert Projects.get_project!(project.id) == project
    end

    alias I18NAPI.Translations
    alias I18NAPI.Projects.UserLocales

    test "create_project/1 with valid data creates a project" do
      user = user_fixture()
      {:ok, project} = Projects.create_project(@valid_project_attrs, user)
      assert %Project{} = project
      assert project.is_removed == false
      assert project.default_locale == @valid_project_attrs.default_locale
      assert project.total_count_of_translation_keys == 0
      locale = Translations.get_default_locale!(project.id)
      user_locale = Projects.get_user_locales!(locale.id, user.id)
      assert %UserLocales{} = user_locale
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_project(@invalid_project_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture(%{}, user_fixture())
      assert {:ok, project} = Projects.update_project(project, @update_project_attrs)
      assert %Project{} = project
      assert project.is_removed == false
      assert project.name == "some updated name"
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = project_fixture(%{}, user_fixture())

      assert {:error, %Ecto.Changeset{}} =
               Projects.update_project(project, @invalid_project_attrs)

      assert project == Projects.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture(%{}, user_fixture())
      assert {:ok, %Project{}} = Projects.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture(%{}, user_fixture())
      assert %Ecto.Changeset{} = Projects.change_project(project)
    end
  end

  describe "user_roles" do
    alias I18NAPI.Projects.UserRoles
    alias EctoEnum

    @valid_attrs %{role: :manager}
    @update_attrs %{role: :translator}
    @invalid_attrs %{role: nil}

    @user_alter_attrs %{
      name: "alter name",
      email: "alter@email.test",
      password: "Qw!23456",
      password_confirmation: "Qw!23456",
      source: "test source"
    }

    def user_roles_fixture(attrs \\ %{}, %User{} = user) do
      project_id = project_fixture(attrs, user).id

      Projects.get_user_roles!(project_id, user.id)
    end

    test "list_user_roles/0 returns all user_roles" do
      user_roles = user_roles_fixture(@valid_project_attrs, user_fixture())
      assert Projects.list_user_roles() == [user_roles]
    end

    test "get_user_roles!/1 returns the user_roles with given id" do
      user_roles = user_roles_fixture(@valid_project_attrs, user_fixture())
      assert Projects.get_user_roles!(user_roles.id) == user_roles
    end

    test "get_user_roles!/2 returns the user_roles with given id" do
      user = user_fixture(@user_attrs)
      project_id = project_fixture(@valid_project_attrs, user).id

      assert %UserRoles{} = Projects.get_user_roles!(project_id, user.id)
    end

    test "create_user_roles/1 with valid data creates a user_roles" do
      user = user_fixture(@user_attrs)
      user_alter = user_fixture(@user_alter_attrs)
      project_id = project_fixture(@valid_project_attrs, user).id
      attrs = @valid_attrs
      # use alternative user because user_role already created on project creating
      attrs = Map.put(attrs, :user_id, user_alter.id)
      attrs = Map.put(attrs, :project_id, project_id)
      assert {:ok, %UserRoles{} = user_roles} = Projects.create_user_roles(attrs)
      assert user_roles.role == :manager
    end

    test "create_user_roles/1 with invalid data returns error changeset" do
      user = user_fixture()
      attrs = @invalid_attrs
      attrs = Map.put(attrs, :user_id, user.id)
      attrs = Map.put(attrs, :project_id, project_fixture(@valid_project_attrs, user).id)
      assert {:error, %Ecto.Changeset{}} = Projects.create_user_roles(attrs)
    end

    test "update_user_roles/2 with valid data updates the user_roles" do
      user_roles = user_roles_fixture(@valid_project_attrs, user_fixture())
      assert {:ok, user_roles} = Projects.update_user_roles(user_roles, @update_attrs)
      assert %UserRoles{} = user_roles
      assert user_roles.role == :translator
    end

    test "update_user_roles/2 with invalid data returns error changeset" do
      user_roles = user_roles_fixture(@valid_project_attrs, user_fixture())
      assert {:error, %Ecto.Changeset{}} = Projects.update_user_roles(user_roles, @invalid_attrs)
      assert user_roles == Projects.get_user_roles!(user_roles.id)
    end

    test "delete_user_roles/1 deletes the user_roles" do
      user_roles = user_roles_fixture(@valid_project_attrs, user_fixture())
      assert {:ok, %UserRoles{}} = Projects.delete_user_roles(user_roles)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_user_roles!(user_roles.id) end
    end

    test "change_user_roles/1 returns a user_roles changeset" do
      user_roles = user_roles_fixture(@valid_project_attrs, user_fixture())
      assert %Ecto.Changeset{} = Projects.change_user_roles(user_roles)
    end
  end

  describe "user_locales" do
    alias I18NAPI.Projects.UserLocales

    @valid_attrs %{role: 0}
    @update_attrs %{role: 1}
    @invalid_attrs %{role: nil}

    def user_locales_fixture(attrs \\ %{}) do
      {:ok, user_locales} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Projects.create_user_locales()

      user_locales
    end

    test "list_user_locales/0 returns all user_locales" do
      user_locales = user_locales_fixture()
      assert Projects.list_user_locales() == [user_locales]
    end

    test "get_user_locales!/1 returns the user_locales with given id" do
      user_locales = user_locales_fixture()
      assert Projects.get_user_locales!(user_locales.id) == user_locales
    end

    test "create_user_locales/1 with valid data creates a user_locales" do
      assert {:ok, %UserLocales{} = user_locales} = Projects.create_user_locales(@valid_attrs)
      assert user_locales.role == 0
    end

    test "create_user_locales/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_user_locales(@invalid_attrs)
    end

    test "update_user_locales/2 with valid data updates the user_locales" do
      user_locales = user_locales_fixture()
      assert {:ok, user_locales} = Projects.update_user_locales(user_locales, @update_attrs)
      assert %UserLocales{} = user_locales
      assert user_locales.role == 1
    end

    test "update_user_locales/2 with invalid data returns error changeset" do
      user_locales = user_locales_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Projects.update_user_locales(user_locales, @invalid_attrs)

      assert user_locales == Projects.get_user_locales!(user_locales.id)
    end

    test "delete_user_locales/1 deletes the user_locales" do
      user_locales = user_locales_fixture()
      assert {:ok, %UserLocales{}} = Projects.delete_user_locales(user_locales)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_user_locales!(user_locales.id) end
    end

    test "change_user_locales/1 returns a user_locales changeset" do
      user_locales = user_locales_fixture()
      assert %Ecto.Changeset{} = Projects.change_user_locales(user_locales)
    end
  end
end
