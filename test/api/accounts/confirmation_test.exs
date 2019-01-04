defmodule I18NAPI.ConfirmationTest do
  use ExUnit.Case, async: true
  @moduletag :confirmation_api

  use I18NAPI.DataCase

  alias I18NAPI.Utilites
  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User
  alias I18NAPI.Accounts.Confirmation

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(I18NAPI.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(I18NAPI.Repo, {:shared, self()})
    :ok
  end

  @user_attrs %{
    name: "test name",
    email: "test@email.test",
    password: "Qw!23456",
    password_confirmation: "Qw!23456",
    source: "test source"
  }

  def user_fixture() do
    {:ok, user} =
      %User{}
      |> User.changeset(Map.put(@user_attrs, :confirmation_token, Utilites.random_string(32)))
      |> Repo.insert()

    user
  end

  describe "confirmation" do
    test "send_confirmation_email" do
      assert {:ok, %User{}} = Confirmation.send_confirmation_email(user_fixture())
    end

    test "confirm_user_by_token" do
      user = user_fixture()
      refute user.is_confirmed

      user =
        with {:ok} <- Confirmation.confirm_user_by_token(user.confirmation_token),
             do: Accounts.get_user!(user.id)

      assert user.is_confirmed
    end
  end
end
