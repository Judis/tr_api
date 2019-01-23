defmodule I18NAPI.MailerTest do
  use ExUnit.Case, async: true
  @moduletag :mailer_api

  use I18NAPI.DataCase
  use I18NAPI.Fixtures, [:setup, :user, :project, :invitation]

  alias Swoosh.TestAssertions

  alias I18NAPI.Projects
  alias I18NAPI.Projects.Invitation
  alias I18NAPI.UserEmail

  test "deliver confirmation email" do
    user = fixture(:user)
    UserEmail.create_confirmation_email(user) |> I18NAPI.Mailer.deliver()
    TestAssertions.assert_email_sent()
  end

  test "deliver restoration email" do
    user = fixture(:user)
    UserEmail.create_restoration_email(user) |> I18NAPI.Mailer.deliver()
    TestAssertions.assert_email_sent()
  end

  test "deliver invite email for confirmed user" do
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

    invite_link = Invitation.create_invitation_project_link(project.id, invite.token)

    UserEmail.create_invite_email_for_confirmed_user(%{
      invite: invite,
      recipient: recipient,
      inviter: inviter,
      project: project,
      invite_link: invite_link
    })
    |> I18NAPI.Mailer.deliver()

    TestAssertions.assert_email_sent()
  end

  test "deliver invite email for unconfirmed user" do
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

    invite_link = Invitation.create_invitation_user_link(invite.token)

    UserEmail.create_invite_email_for_not_unconfirmed_user(%{
      invite: invite,
      recipient: recipient,
      inviter: inviter,
      project: project,
      invite_link: invite_link
    })
    |> I18NAPI.Mailer.deliver()

    TestAssertions.assert_email_sent()
  end
end
