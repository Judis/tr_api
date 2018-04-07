defmodule I18NAPI.AccountsTest do
  use I18NAPI.DataCase

  alias I18NAPI.Accounts

  describe "users" do
    alias I18NAPI.Accounts.User

    @valid_attrs %{confirmation_sent_at: ~N[2010-04-17 14:00:00.000000], confirmation_token: "some confirmation_token", confirmed_at: ~N[2010-04-17 14:00:00.000000], email: "some email", failed_restore_attempts: 42, failed_sign_in_attempts: 42, invited_at: ~N[2010-04-17 14:00:00.000000], is_confirmed: true, last_visited_at: ~N[2010-04-17 14:00:00.000000], name: "some name", password_hash: "some password_hash", restore_accepted_at: ~N[2010-04-17 14:00:00.000000], restore_requested_at: ~N[2010-04-17 14:00:00.000000], restore_token: "some restore_token", source: "some source"}
    @update_attrs %{confirmation_sent_at: ~N[2011-05-18 15:01:01.000000], confirmation_token: "some updated confirmation_token", confirmed_at: ~N[2011-05-18 15:01:01.000000], email: "some updated email", failed_restore_attempts: 43, failed_sign_in_attempts: 43, invited_at: ~N[2011-05-18 15:01:01.000000], is_confirmed: false, last_visited_at: ~N[2011-05-18 15:01:01.000000], name: "some updated name", password_hash: "some updated password_hash", restore_accepted_at: ~N[2011-05-18 15:01:01.000000], restore_requested_at: ~N[2011-05-18 15:01:01.000000], restore_token: "some updated restore_token", source: "some updated source"}
    @invalid_attrs %{confirmation_sent_at: nil, confirmation_token: nil, confirmed_at: nil, email: nil, failed_restore_attempts: nil, failed_sign_in_attempts: nil, invited_at: nil, is_confirmed: nil, last_visited_at: nil, name: nil, password_hash: nil, restore_accepted_at: nil, restore_requested_at: nil, restore_token: nil, source: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.confirmation_sent_at == ~N[2010-04-17 14:00:00.000000]
      assert user.confirmation_token == "some confirmation_token"
      assert user.confirmed_at == ~N[2010-04-17 14:00:00.000000]
      assert user.email == "some email"
      assert user.failed_restore_attempts == 42
      assert user.failed_sign_in_attempts == 42
      assert user.invited_at == ~N[2010-04-17 14:00:00.000000]
      assert user.is_confirmed == true
      assert user.last_visited_at == ~N[2010-04-17 14:00:00.000000]
      assert user.name == "some name"
      assert user.password_hash == "some password_hash"
      assert user.restore_accepted_at == ~N[2010-04-17 14:00:00.000000]
      assert user.restore_requested_at == ~N[2010-04-17 14:00:00.000000]
      assert user.restore_token == "some restore_token"
      assert user.source == "some source"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.confirmation_sent_at == ~N[2011-05-18 15:01:01.000000]
      assert user.confirmation_token == "some updated confirmation_token"
      assert user.confirmed_at == ~N[2011-05-18 15:01:01.000000]
      assert user.email == "some updated email"
      assert user.failed_restore_attempts == 43
      assert user.failed_sign_in_attempts == 43
      assert user.invited_at == ~N[2011-05-18 15:01:01.000000]
      assert user.is_confirmed == false
      assert user.last_visited_at == ~N[2011-05-18 15:01:01.000000]
      assert user.name == "some updated name"
      assert user.password_hash == "some updated password_hash"
      assert user.restore_accepted_at == ~N[2011-05-18 15:01:01.000000]
      assert user.restore_requested_at == ~N[2011-05-18 15:01:01.000000]
      assert user.restore_token == "some updated restore_token"
      assert user.source == "some updated source"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
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
