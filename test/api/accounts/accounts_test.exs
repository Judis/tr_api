defmodule I18NAPI.AccountsTest do
  use I18NAPI.DataCase

  alias I18NAPI.Accounts

  describe "users" do
    alias I18NAPI.Accounts.User

    @valid_attrs %{
      email: "user@test.com",
      name: "some name",
      password: "Passw0rd",
      password_confirmation: "Passw0rd"
    }
    @update_attrs %{
      email: "user@test.com",
      name: "some updated name",
    }
    @invalid_attrs %{
      email: nil,
      name: nil,
      password: nil,
      password_confirmation: nil
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      |> Map.replace!(:password, nil)
      |> Map.replace!(:password_confirmation, nil)

      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      |> Map.replace!(:password, nil)
      |> Map.replace!(:password_confirmation, nil)
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "user@test.com"
      assert user.name == "some name"
      assert user.password_hash != nil
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      |> Map.replace!(:password, nil)
      |> Map.replace!(:password_confirmation, nil)

      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
