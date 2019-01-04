defmodule I18NAPIWeb.RestorationControllerTest do
  use ExUnit.Case, async: true
  @moduletag :restoration_controller

  use I18NAPIWeb.ConnCase

  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.Restoration
  alias I18NAPI.Accounts.User
  alias I18NAPI.Repo
  alias I18NAPI.Utilites

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
      |> User.changeset(Map.put(@fixture_user_attrs, :restore_token, Utilites.random_string(32)))
      |> Repo.insert()

    Restoration.send_password_restore_email(user)
    Accounts.get_user!(user.id)
  end

  describe "restoration user password" do
    test "if token is valid", %{conn: conn} do
      user = fixture(:user)
      new_password = "Zxcv1234!"

      conn =
        post(
          conn,
          restoration_path(conn, :reset, %{}),
          user: %{
            restore_token: user.restore_token,
            password: new_password,
            password_confirmation: new_password
          }
        )

      assert json_response(conn, 200)
      assert %User{} = Accounts.get_user!(user.id)

      assert {:ok, %User{}} =
               Accounts.find_and_confirm_user(@fixture_user_attrs.email, new_password)
    end

    test "if token is invalid", %{conn: conn} do
      user = fixture(:user)
      new_password = "Zxcv1234!"

      conn =
        post(
          conn,
          restoration_path(conn, :reset, %{}),
          user: %{
            restore_token: "invalid_token",
            password: new_password,
            password_confirmation: new_password
          }
        )

      assert json_response(conn, 200)
      assert %User{} = Accounts.get_user!(user.id)

      assert {:error, :unauthorized} =
               Accounts.find_and_confirm_user(@fixture_user_attrs.email, new_password)
    end

    test "if token is nil", %{conn: conn} do
      user = fixture(:user)
      new_password = "Zxcv1234!"

      conn =
        post(
          conn,
          restoration_path(conn, :reset, %{}),
          user: %{
            restore_token: nil,
            password: new_password,
            password_confirmation: new_password
          }
        )

      assert json_response(conn, 400)
      assert %User{} = Accounts.get_user!(user.id)
    end

    test "if new password invalid", %{conn: conn} do
      user = fixture(:user)
      new_password = "Zxcv"

      conn =
        post(
          conn,
          restoration_path(conn, :reset, %{}),
          user: %{
            restore_token: user.restore_token,
            password: new_password,
            password_confirmation: new_password
          }
        )

      assert json_response(conn, 422)

      assert conn.resp_body =~
               "Password must have 8-255 symbols, include at least one lowercase letter, one uppercase letter, and one digit"

      assert %User{} = Accounts.get_user!(user.id)
    end

    test "if new password unconfirmed", %{conn: conn} do
      user = fixture(:user)
      new_password = "Zxcv1234!"

      conn =
        post(
          conn,
          restoration_path(conn, :reset, %{}),
          user: %{
            restore_token: user.restore_token,
            password: new_password,
            password_confirmation: "nsdvjsdv&^*^^^&*^*767856"
          }
        )

      assert json_response(conn, 422)
      assert conn.resp_body =~ "Does not match confirmation"
      assert %User{} = Accounts.get_user!(user.id)
    end

    test "if new password nil", %{conn: conn} do
      user = fixture(:user)

      conn =
        post(
          conn,
          restoration_path(conn, :reset, %{}),
          user: %{
            restore_token: user.restore_token,
            password: nil,
            password_confirmation: nil
          }
        )

      assert json_response(conn, 400)
      assert conn.resp_body =~ "Bad Request"
      assert %User{} = Accounts.get_user!(user.id)
    end
  end
end
