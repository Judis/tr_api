defmodule I18NAPI.MailerTest do
  use ExUnit.Case, async: true
  use I18NAPI.DataCase

  @moduletag :mailer_api

  import Swoosh.TestAssertions

  alias I18NAPI.Accounts.User
  alias I18NAPI.Projects
  alias I18NAPI.UserEmail
  alias I18NAPI.Utilities
  @user_attrs %{
    name: "test name",
    email: "test@email.test",
    password: "Qw!23456",
    password_confirmation: "Qw!23456",
    source: "test source"
  }

  @additional_user_attrs %{
    name: "additional name",
    email: "additional@email.test",
    password: "Qw!23456",
    password_confirmation: "Qw!23456",
    source: "additional source"
  }

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      %User{}
      |> User.changeset(attrs |> Enum.into(@user_attrs))
      |> Repo.insert()

    user |> Map.put(:confirmation_token, Utilities.random_string(25))
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

  test "deliver confirmation email" do
    UserEmail.create_confirmation_email(user_fixture()) |> I18NAPI.Mailer.deliver()
    assert_email_sent()
  end

  test "deliver restoration email" do
    UserEmail.create_restoration_email(user_fixture()) |> I18NAPI.Mailer.deliver()
    assert_email_sent()
  end

  test "deliver invitation email" do
    user = user_fixture()
    UserEmail.create_invitation_email(
      user_fixture(@additional_user_attrs),
      user,
      project_fixture(user),
      :translator,
      "some message"
    )
 |> I18NAPI.Mailer.deliver()
    assert_email_sent()
  end
end
