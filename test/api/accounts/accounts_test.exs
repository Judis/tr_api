defmodule I18NAPI.AccountsTest do
  use ExUnit.Case, async: true
  @moduletag :account_api

  use I18NAPI.DataCase

  alias I18NAPI.Accounts

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(I18NAPI.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(I18NAPI.Repo, {:shared, self()})
    :ok
  end

  describe "users" do
    alias I18NAPI.Accounts.User

    @valid_attrs %{
      name: "test name",
      email: "test@email.test",
      password: "Qw!23456",
      password_confirmation: "Qw!23456",
      source: "test source"
    }

    @update_attrs %{
      name: "test altername",
      email: "alter@email.test",
      password: "Qw!2345678",
      password_confirmation: "Qw!2345678",
      source: "alter source"
    }
    @invalid_attrs %{
      name: nil,
      email: nil,
      password: nil,
      password_confirmation: nil,
      source: nil
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user_fixture()
      assert [%User{} | _] = Accounts.list_users()
    end

    test "get_user!/1 returns the user with given id" do
      user_prepared = user_fixture()
      #      assert Accounts.get_user!(user.id) == user
      assert %User{} = user = Accounts.get_user!(user_prepared.id)
      assert user.name == user_prepared.name
      assert user.email == user_prepared.email
      assert user.password_hash == user_prepared.password_hash
      assert user.source == user_prepared.source
      assert user.invited_at == user_prepared.invited_at
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.name == @valid_attrs.name
      assert user.email == @valid_attrs.email
      assert user.is_confirmed == false
      assert user.password_hash =~ ~r/^\$2[ayb]\$.{56}$/
      assert user.source == @valid_attrs.source
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user_prepared = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user_prepared, @update_attrs)
      assert user.name == @update_attrs.name
      assert user.email == @update_attrs.email
      assert user.is_confirmed == false
      assert user.password_hash =~ ~r/^\$2[ayb]\$.{56}$/
      assert user.source == @update_attrs.source

      assert DateTime.from_naive!(user.updated_at, "Etc/UTC") >
               DateTime.from_naive!(user_prepared.updated_at, "Etc/UTC")
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert %User{} = user = Accounts.get_user!(user.id)
      assert user.name == @valid_attrs.name
      assert user.email == @valid_attrs.email
      assert user.is_confirmed == false
      assert user.password_hash =~ ~r/^\$2[ayb]\$.{56}$/
      assert user.source == @valid_attrs.source
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
