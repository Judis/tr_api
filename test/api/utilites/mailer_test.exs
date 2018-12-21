defmodule I18NAPI.MailerTest do
  use ExUnit.Case, async: true
  use I18NAPI.DataCase

  @moduletag :mailer_api

  import Swoosh.TestAssertions
  import Swoosh.TestAssertions

  alias I18NAPI.UserEmail
  alias I18NAPI.Utilites
  alias I18NAPI.Accounts.User

  @user_attrs %{
    name: "test name",
    email: "test@email.test",
    password: "Qw!23456",
    password_confirmation: "Qw!23456",
    source: "test source",
  }

  def user_fixture(attrs \\ %{}) do
    {:ok, user} = %User{}
                  |> User.changeset(attrs |> Enum.into(@user_attrs))
                  |> Repo.insert()

    user |> Map.put(:confirmation_token, Utilites.random_string(25))
  end

  test "deliver confirmation email" do
    UserEmail.create_confirmation_email(user_fixture()) |> I18NAPI.Mailer.deliver
    assert_email_sent()
  end

  test "deliver restoration email" do
    UserEmail.create_restoration_email(user_fixture()) |> I18NAPI.Mailer.deliver
    assert_email_sent()
  end

  test "deliver restoration email" do
    UserEmail.create_restoration_email(user_fixture()) |> I18NAPI.Mailer.deliver
    assert_email_sent()
  end
end
