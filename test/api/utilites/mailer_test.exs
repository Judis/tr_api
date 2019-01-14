defmodule I18NAPI.MailerTest do
  use ExUnit.Case, async: true
  @moduletag :mailer_api

  use I18NAPI.DataCase
  use I18NAPI.Fixtures, [:setup, :user, :project]

  import Swoosh.TestAssertions

  alias I18NAPI.Accounts.User
  alias I18NAPI.Projects
  alias I18NAPI.UserEmail
  alias I18NAPI.Utilities

  test "deliver confirmation email" do
    user = fixture(:user)
    UserEmail.create_confirmation_email(user) |> I18NAPI.Mailer.deliver()
    assert_email_sent()
  end

  test "deliver restoration email" do
    user = fixture(:user)
    UserEmail.create_restoration_email(user) |> I18NAPI.Mailer.deliver()
    assert_email_sent()
  end

  test "deliver invitation email" do
    user = fixture(:user)
    user_alter = fixture(:user_alter)
    project = fixture(:project, user: user)
    UserEmail.create_invitation_email(
      user_alter,
      user,
      project,
      :translator,
      "some message"
    )
 |> I18NAPI.Mailer.deliver()
    assert_email_sent()
  end
end
