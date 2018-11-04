defmodule I18NAPI.ProjectsTest do
  use ExUnit.Case, async: true
  @moduletag :project_api

  use I18NAPI.DataCase

  alias I18NAPI.Projects

  describe "projects" do
    alias I18NAPI.Projects.Project
    alias I18NAPI.Accounts


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
    @valid_attrs %{
      name: "some name",
      default_locale: "en"
    }
    @update_attrs %{
      name: "some updated name"
      #      is_removed: false,
      #      removed_at: ~N[2011-05-18 15:01:01.000000]
    }
    @invalid_attrs %{name: nil, default_locale: nil, is_removed: nil, removed_at: nil}

    def project_fixture(attrs \\ %{}) do
      {:ok, project} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Projects.create_project(user_fixture())

      project
    end

    test "list_projects/0 returns all projects" do
      project = project_fixture()
      assert Projects.list_projects() == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert Projects.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      assert {:ok, %Project{} = project} = Projects.create_project(@valid_attrs, user_fixture())
      assert project.is_removed == false
      assert project.default_locale == @valid_attrs.default_locale
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()
      assert {:ok, project} = Projects.update_project(project, @update_attrs)
      assert %Project{} = project
      assert project.is_removed == false
      assert project.name == "some updated name"
      assert project.removed_at == ~N[2011-05-18 15:01:01.000000]
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = Projects.update_project(project, @invalid_attrs)
      assert project == Projects.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = Projects.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture()
      assert %Ecto.Changeset{} = Projects.change_project(project)
    end
  end

  describe "user_roles" do
    alias I18NAPI.Projects.UserRoles

    @valid_attrs %{role: 42}
    @update_attrs %{role: 43}
    @invalid_attrs %{role: nil}

    def user_roles_fixture(attrs \\ %{}) do
      {:ok, user_roles} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Projects.create_user_roles()

      user_roles
    end

    test "list_user_roles/0 returns all user_roles" do
      user_roles = user_roles_fixture()
      assert Projects.list_user_roles() == [user_roles]
    end

    test "get_user_roles!/1 returns the user_roles with given id" do
      user_roles = user_roles_fixture()
      assert Projects.get_user_roles!(user_roles.id) == user_roles
    end

    test "create_user_roles/1 with valid data creates a user_roles" do
      assert {:ok, %UserRoles{} = user_roles} = Projects.create_user_roles(@valid_attrs)
      assert user_roles.role == 42
    end

    test "create_user_roles/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_user_roles(@invalid_attrs)
    end

    test "update_user_roles/2 with valid data updates the user_roles" do
      user_roles = user_roles_fixture()
      assert {:ok, user_roles} = Projects.update_user_roles(user_roles, @update_attrs)
      assert %UserRoles{} = user_roles
      assert user_roles.role == 43
    end

    test "update_user_roles/2 with invalid data returns error changeset" do
      user_roles = user_roles_fixture()
      assert {:error, %Ecto.Changeset{}} = Projects.update_user_roles(user_roles, @invalid_attrs)
      assert user_roles == Projects.get_user_roles!(user_roles.id)
    end

    test "delete_user_roles/1 deletes the user_roles" do
      user_roles = user_roles_fixture()
      assert {:ok, %UserRoles{}} = Projects.delete_user_roles(user_roles)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_user_roles!(user_roles.id) end
    end

    test "change_user_roles/1 returns a user_roles changeset" do
      user_roles = user_roles_fixture()
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
