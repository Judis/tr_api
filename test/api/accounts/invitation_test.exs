defmodule I18NAPI.InvitationTest do
  use ExUnit.Case, async: true
  @moduletag :invitation_api

  use I18NAPI.DataCase
  use I18NAPI.Fixtures, [:setup, :user, :project]

  alias I18NAPI.Accounts.{Invitation, User}

  describe "invitation" do
    @invite_user_data %{
      name: "invited user",
      email: "invited@email.test",
      role: :translator,
      message: "some message"
    }

    test "send_invite_email_async" do
      owner = fixture(:user)
      user = fixture(:user_alter)
      project = fixture(:project, user: owner)
      assert {:ok, %User{}} = Invitation.send_invite_email_async({:ok, user}, owner, project, :translator, "message")
    end

    test "send_invite_email with prepared user" do
      owner = fixture(:user)
      user = fixture(:user_alter)
      project = fixture(:project, user: owner)
      prepared_data = @invite_user_data |> Map.put(:project_id, project.id)
      {:ok, prepared_user} = Invitation.prepare_user(:manager, prepared_data, owner)
      assert {:ok, %User{} = user} = Invitation.send_invite_email(prepared_user, owner, project, :translator, "message")
      assert user.invited_at
    end

    test "start_invite_creating(user_params, owner)" do
      owner = fixture(:user)
      user = fixture(:user_alter)
      project = fixture(:project, user: owner)
      prepared_data = @invite_user_data |> Map.put(:project_id, project.id)
      assert {:ok, %User{} = user} = Invitation.start_invite_creating(prepared_data, owner)
      refute user.invited_at #because include async function

    end

    test "prepare_user when :admin == role" do
      owner = fixture(:user)
      user = fixture(:user_alter)
      project = fixture(:project, user: owner)
      prepared_data = @invite_user_data |> Map.put(:project_id, project.id)
      assert {:ok, %User{} = user} = Invitation.prepare_user(:admin, prepared_data, owner)
    end

    test "prepare_user when :manager == role" do
      owner = fixture(:user)
      user = fixture(:user_alter)
      project = fixture(:project, user: owner)
      prepared_data = @invite_user_data |> Map.put(:project_id, project.id)
      assert {:ok, %User{} = user} = Invitation.prepare_user(:manager, prepared_data, owner)
    end

    test "prepare_user when role not authorized" do
      owner = fixture(:user)
      user = fixture(:user_alter)
      project = fixture(:project, user: owner)
      assert {:error, :access_denied} = Invitation.prepare_user(:translator, @invite_user_data, owner)
    end

    test "accept_user_by_token(restore_token, password, password_confirmation)" do
      owner = fixture(:user)
      user = fixture(:user_alter)
      project = fixture(:project, user: owner)
      prepared_data = @invite_user_data |> Map.put(:project_id, project.id)
      {:ok, prepared_user} = Invitation.prepare_user(:manager, prepared_data, owner)
      assert {:ok, %User{} = user} = Invitation.send_invite_email(prepared_user, owner, project, :translator, "message")
      assert user.invited_at

      assert {:ok, %User{} = user} = Invitation.accept_user_by_token(user.restore_token, "Qwerty123!", "Qwerty123!")
      refute user.invited_at
      refute user.restore_token
      refute user.confirmation_token
      assert user.is_confirmed
    end

    test "create_invitation_link(restore_token)" do
      assert Invitation.create_invitation_link("abcde")
    end
  end
end
