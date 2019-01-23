defmodule I18NAPI.ProjectsTest do
  use ExUnit.Case, async: true
  @moduletag :project_api

  use I18NAPI.DataCase
  use I18NAPI.Fixtures, [:setup, :user, :project, :invitation, :user_role]

  alias EctoEnum
  alias I18NAPI.Accounts.User
  alias I18NAPI.Projects
  alias I18NAPI.Projects.{Invite, Project, UserLocales, UserRole}
  alias I18NAPI.Translations

  describe "projects" do
    test "list_projects/0 returns all projects" do
      project = fixture(:project, user: fixture(:user))
      assert Projects.list_projects() == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = fixture(:project, user: fixture(:user))
      assert Projects.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      user = fixture(:user)
      {:ok, project} = Projects.create_project(attrs(:project), user)
      assert %Project{} = project
      assert project.is_removed == false
      assert project.default_locale == attrs(:project).default_locale
      assert project.total_count_of_translation_keys == 0
      locale = Translations.get_default_locale!(project.id)
      user_locale = Projects.get_user_locales!(locale.id, user.id)
      assert %UserLocales{} = user_locale
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_project(attrs(:project_nil))
    end

    test "update_project/2 with valid data updates the project" do
      project = fixture(:project, user: fixture(:user))
      assert {:ok, project} = Projects.update_project(project, attrs(:project_alter))
      assert %Project{} = project
      assert project.is_removed == false
      assert project.name == attrs(:project_alter).name
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = fixture(:project, user: fixture(:user))

      assert {:error, %Ecto.Changeset{}} = Projects.update_project(project, attrs(:project_nil))

      assert project == Projects.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = fixture(:project, user: fixture(:user))
      assert {:ok, %Project{}} = Projects.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = fixture(:project, user: fixture(:user))
      assert %Ecto.Changeset{} = Projects.change_project(project)
    end
  end

  describe "user_role" do
    def user_role_fixture(_, %User{} = user) do
      project_id = fixture(:project, user: user).id

      Projects.get_user_role!(project_id, user.id)
    end

    test "list_user_roles/0 returns all user_roles" do
      user = fixture(:user)

      user_role =
        fixture(:user_role, %{project_id: fixture(:project, user: user).id, user_id: user.id})

      assert Projects.list_user_roles() == [user_role]
    end

    test "get_user_role!/1 returns the user_role with given id" do
      user = fixture(:user)

      user_role =
        fixture(:user_role, %{project_id: fixture(:project, user: user).id, user_id: user.id})

      assert Projects.get_user_role!(user_role.id) == user_role
    end

    test "get_user_role!/2 returns the user_role with given id" do
      user = fixture(:user)
      project_id = fixture(:project, user: user).id
      assert %UserRole{} = Projects.get_user_role!(project_id, user.id)
    end

    test "create_user_role/1 with valid data creates a user_role" do
      user = fixture(:user)
      user_alter = fixture(:user_alter)
      project_id = fixture(:project, user: user).id
      attrs = attrs(:user_role)
      # use alternative user because user_role already created on project creating
      attrs = Map.put(attrs, :user_id, user_alter.id)
      attrs = Map.put(attrs, :project_id, project_id)
      assert {:ok, %UserRole{} = user_role} = Projects.create_user_role(attrs)
      assert user_role.role == attrs(:user_role).role
    end

    test "create_user_role/1 with invalid data returns error changeset" do
      user = fixture(:user)
      attrs = attrs(:user_role_nil)
      attrs = Map.put(attrs, :user_id, user.id)
      attrs = Map.put(attrs, :project_id, fixture(:project, user: user).id)
      assert {:error, %Ecto.Changeset{}} = Projects.create_user_role(attrs)
    end

    test "update_user_role/2 with valid data updates the user_role" do
      user = fixture(:user)

      user_role =
        fixture(:user_role, %{project_id: fixture(:project, user: user).id, user_id: user.id})

      assert {:ok, user_role} =
               Projects.update_user_role(user_role, attrs(:user_role_translator))

      assert %UserRole{} = user_role
      assert user_role.role == attrs(:user_role_translator).role
    end

    test "update_user_role/2 with invalid data returns error changeset" do
      user = fixture(:user)

      user_role =
        fixture(:user_role, %{project_id: fixture(:project, user: user).id, user_id: user.id})

      assert {:error, %Ecto.Changeset{}} =
               Projects.update_user_role(user_role, attrs(:user_role_nil))

      assert user_role == Projects.get_user_role!(user_role.id)
    end

    test "delete_user_role/1 deletes the user_role" do
      user = fixture(:user)

      user_role =
        fixture(:user_role, %{project_id: fixture(:project, user: user).id, user_id: user.id})

      assert {:ok, %UserRole{}} = Projects.delete_user_role(user_role)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_user_role!(user_role.id) end
    end

    test "change_user_role/1 returns a user_role changeset" do
      user = fixture(:user)
      tmp = %{project_id: fixture(:project, %{user: user}).id, user_id: user.id}
      user_role = fixture(:user_role, tmp)
      assert %Ecto.Changeset{} = Projects.change_user_role(user_role)
    end
  end

  describe "user_locales" do
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

  describe "invite" do
    #    test "list_invite/0 returns all projects" do
    #      project = fixture(:project, [user: fixture(:user)])
    #      assert Projects.list_projects() == [project]
    #    end

    test "get_invite!/1 returns the invite with given id" do
      inviter = fixture(:user)
      recipient_id = fixture(:user_alter).id
      project_id = fixture(:project, user: inviter).id

      invite =
        fixture(:invite, %{
          inviter_id: inviter.id,
          recipient_id: recipient_id,
          project_id: project_id
        })

      assert Projects.get_invite!(invite.id) == invite
    end

    test "create_invite/1 with valid data" do
      inviter = fixture(:user)
      recipient_id = fixture(:user_alter).id
      project_id = fixture(:project, user: inviter).id

      attrs =
        attrs(:invite)
        |> Map.merge(%{inviter_id: inviter.id, recipient_id: recipient_id, project_id: project_id})

      assert {:ok, %Invite{}} = Projects.create_invite(attrs)
    end

    test "create_invite/1 with nullable data" do
      inviter = fixture(:user)
      recipient_id = fixture(:user_alter).id
      project_id = fixture(:project, user: inviter).id

      attrs =
        attrs(:invite_nil)
        |> Map.merge(%{inviter_id: inviter.id, recipient_id: recipient_id, project_id: project_id})

      assert {:error, %Ecto.Changeset{}} = Projects.create_invite(attrs)
    end

    test "update_invite/1 with valid data" do
      inviter = fixture(:user)
      recipient_id = fixture(:user_alter).id
      project_id = fixture(:project, user: inviter).id

      invite =
        fixture(:invite, %{
          inviter_id: inviter.id,
          recipient_id: recipient_id,
          project_id: project_id
        })

      assert {:ok, %Invite{}} = Projects.update_invite(invite, attrs(:invite_alter))
      invite_alter = Projects.get_invite!(invite.id)

      assert invite_alter.message == attrs(:invite_alter).message
      assert invite_alter.role == attrs(:invite_alter).role
      assert invite_alter.is_removed == attrs(:invite_alter).is_removed
      assert invite_alter.token == attrs(:invite_alter).token
    end

    test "update_invite/1 with invalid data" do
      inviter = fixture(:user)
      recipient_id = fixture(:user_alter).id
      project_id = fixture(:project, user: inviter).id

      invite =
        fixture(:invite, %{
          inviter_id: inviter.id,
          recipient_id: recipient_id,
          project_id: project_id
        })

      assert {:error, %Ecto.Changeset{}} = Projects.update_invite(invite, attrs(:invite_nil))
    end

    test "delete_invite!/1 delete the invite" do
      inviter = fixture(:user)
      recipient_id = fixture(:user_alter).id
      project_id = fixture(:project, user: inviter).id

      invite =
        fixture(:invite, %{
          inviter_id: inviter.id,
          recipient_id: recipient_id,
          project_id: project_id
        })

      Projects.delete_invite(invite)

      assert Projects.get_invite(invite.id) |> is_nil
    end

    test "safely_delete_invite!/1 safely delete the invite" do
      inviter = fixture(:user)
      recipient_id = fixture(:user_alter).id
      project_id = fixture(:project, user: inviter).id

      invite =
        fixture(:invite, %{
          inviter_id: inviter.id,
          recipient_id: recipient_id,
          project_id: project_id
        })

      assert invite.is_removed == false

      Projects.safely_delete_invite(invite)
      assert Projects.get_invite(invite.id).is_removed == true
    end
  end
end
