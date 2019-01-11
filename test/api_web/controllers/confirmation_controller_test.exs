defmodule I18NAPIWeb.ConfirmationControllerTest do
  use ExUnit.Case, async: true
  @moduletag :confirmation_controller

  use I18NAPIWeb.ConnCase

  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.Confirmation
  alias I18NAPI.Accounts.User
  alias I18NAPI.Repo
  alias I18NAPI.Utilities

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(I18NAPI.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(I18NAPI.Repo, {:shared, self()})
    :ok
  end

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(I18NAPI.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(I18NAPI.Repo, {:shared, self()})
    :ok
  end

  @fixture_user_attrs %{
    name: "fixture name",
    email: "fixture@email.test",
    password: "Qw!23456",
    password_confirmation: "Qw!23456",
    source: "fixture source"
  }

  def fixture(:user) do
    {:ok, user} =
      %User{}
      |> User.changeset(
        Map.put(@fixture_user_attrs, :confirmation_token, Utilities.random_string(32))
      )
      |> Repo.insert()

    Confirmation.send_confirmation_email(user)
    Accounts.get_user!(user.id)
  end

  describe "confirmate user email" do
    test "if token is valid", %{conn: conn} do
      user = fixture(:user)
      conn = post(conn, confirmation_path(conn, :confirm, token: user.confirmation_token))
      assert json_response(conn, 200)

      assert %User{} = user = Accounts.get_user!(user.id)
      assert user.is_confirmed
      refute user.confirmation_token
    end

    test "if token is invalid", %{conn: conn} do
      user = fixture(:user)
      conn = post(conn, confirmation_path(conn, :confirm, token: "abracadabra"))
      assert json_response(conn, 404)

      assert %User{} = user = Accounts.get_user!(user.id)
      refute user.is_confirmed
      assert user.confirmation_token
    end

    test "if token is nil", %{conn: conn} do
      user = fixture(:user)
      conn = post(conn, confirmation_path(conn, :confirm, token: nil))
      assert json_response(conn, 404)

      assert %User{} = user = Accounts.get_user!(user.id)
      refute user.is_confirmed
      assert user.confirmation_token
    end
  end
end
