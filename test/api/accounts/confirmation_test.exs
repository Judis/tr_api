defmodule I18NAPI.ConfirmationTest do
  use ExUnit.Case, async: true
  @moduletag :confirmation_api

  use I18NAPI.DataCase

  alias I18NAPI.Utilites
  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User
  alias I18NAPI.Accounts.Confirmation

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

    {:ok, user |> Map.put(:confirmation_token, Utilites.random_string(32))}
  end

  def unconfirmed_user_fixture(token) do
    {:ok, user} = user_fixture()
    attrs = %{
      confirmation_token: token,
      confirmed_at: nil,
      is_confirmed: false
    }
    user
    |> User.confirmation_changeset(attrs)
    |> Repo.update()

  end

  describe "confirmation" do
    test "send_confirmation_email" do
      assert {:ok, %User{}} = Confirmation.send_confirmation_email(user_fixture())
    end

    test"confirm_user_by_token" do
      token =  Utilites.random_string(32)

      {:ok, user} = unconfirmed_user_fixture(token)
      refute user.is_confirmed

      user = with {:ok} <- Confirmation.confirm_user_by_token(token), do:
        Accounts.get_user!(user.id)

      assert user.is_confirmed
    end
  end
end
