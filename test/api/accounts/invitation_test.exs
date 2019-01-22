defmodule I18NAPI.InvitationTest do
  use ExUnit.Case, async: true
  @moduletag :invitation_api

  use I18NAPI.DataCase
  use I18NAPI.Fixtures, [:setup, :user, :project, :invitation]

  alias I18NAPI.Accounts.User
  alias I18NAPI.Projects
  alias I18NAPI.Projects.{Invite, Invitation}

  describe "invitation" do
    test "send_invite_email_async for exists" do
      inviter = fixture(:user)
      recipient = fixture(:user_alter)
      project = fixture(:project, user: inviter)

      {:ok, invite_fix} =
        Projects.create_invite(
          Map.merge(attrs(:invite), %{
            inviter_id: inviter.id,
            recipient_id: recipient.id,
            project_id: project.id
          })
        )

      assert {:ok, %Invite{}} =
               Invitation.send_invite_email_async(
                 {:ok, invite_fix},
                 recipient,
                 inviter,
                 project,
                 :exist
               )
    end

    test "send_invite_email_async for not exists" do
      inviter = fixture(:user)
      recipient = fixture(:user_alter)
      project = fixture(:project, user: inviter)

      {:ok, invite_fix} =
        Projects.create_invite(
          Map.merge(attrs(:invite), %{
            inviter_id: inviter.id,
            recipient_id: recipient.id,
            project_id: project.id
          })
        )

      assert {:ok, %Invite{}} =
               Invitation.send_invite_email_async(
                 {:ok, invite_fix},
                 recipient,
                 inviter,
                 project,
                 :not_exist
               )
    end

    test "send_invite_email with prepared user" do
      inviter = fixture(:user)
      recipient = fixture(:user_alter)
      project = fixture(:project, user: inviter)

      {:ok, invite} =
        Projects.create_invite(
          Map.merge(attrs(:invite), %{
            inviter_id: inviter.id,
            recipient_id: recipient.id,
            project_id: project.id
          })
        )

      assert Invitation.create_link_and_send_email_for_confirmed_user(
               {:ok, invite},
               recipient,
               inviter,
               project
             ) =~ invite.token
    end

    test "prepare user" do
      inviter = fixture(:user)
      project = fixture(:project, user: inviter)
      prepared_data = attrs(:invite) |> Map.put(:project_id, project.id)
      assert {:ok, %User{} = user} = Invitation.prepare_user(prepared_data)
    end

    test "accept_user_by_token(token, password, password_confirmation)" do
      inviter = fixture(:user)
      project = fixture(:project, user: inviter)
      prepared_data = attrs(:invite) |> Map.put(:project_id, project.id)
      recipient = fixture(:user_alter)

      invite_fix =
        fixture(:invite,
          invite:
            prepared_data
            |> Map.put(:recipient_id, recipient.id)
            |> Map.put(:inviter_id, inviter.id)
        )

      assert Map.get(invite_fix, :invited_at)

      assert {:ok, %User{} = user} =
               Invitation.accept_user_by_token(invite_fix.token, "Qwerty123!", "Qwerty123!")

      new_invite = Projects.get_invite(invite_fix.id)
      refute new_invite.token
      refute user.confirmation_token
      assert user.is_confirmed
    end

    test "create_invitation_user_link(token)" do
      assert Invitation.create_invitation_user_link("abcde")
    end

    test "create_invitation_project_link(project_id, token)" do
      assert Invitation.create_invitation_project_link(1, "abcde")
    end
  end
end
