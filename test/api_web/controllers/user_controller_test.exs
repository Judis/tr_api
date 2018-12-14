defmodule I18NAPIWeb.UserControllerTest do
  use ExUnit.Case, async: true
  @moduletag :user_controller

  use I18NAPIWeb.ConnCase

  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User

  @create_attrs %{
    name: "test name",
    email: "test@email.test",
    password: "Qw!23456",
    password_confirmation: "Qw!23456",
    source: "test source"
  }
  @update_attrs %{
    name: "test updated name",
    email: "test_updated@email.test",
    password: "Qw!23456",
    password_confirmation: "Qw!23456",
    source: "test source"
  }
  @invalid_attrs %{
    confirmation_sent_at: nil,
    confirmation_token: nil,
    confirmed_at: nil,
    email: nil,
    failed_restore_attempts: nil,
    failed_sign_in_attempts: nil,
    invited_at: nil,
    is_confirmed: nil,
    last_visited_at: nil,
    name: nil,
    password_hash: nil,
    restore_accepted_at: nil,
    restore_requested_at: nil,
    restore_token: nil,
    source: nil
  }

  @fixture_user_attrs %{
    name: "fixture name",
    email: "fixture@email.test",
    password: "Qw!23456",
    password_confirmation: "Qw!23456",
    source: "fixture source"
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@fixture_user_attrs)
    user
  end

  def fixture(:alter_user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    user = fixture(:user)
    {:ok, jwt, _claims} = I18NAPI.Guardian.encode_and_sign(user)
    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{jwt}")

    {:ok, conn: conn}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, user_path(conn, :index))
      [result|a] = json_response(conn, 200)["data"]
      assert result["name"] == @fixture_user_attrs.name
      assert result["email"] == @fixture_user_attrs.email
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, user_path(conn, :create), user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      assert %User{} = user = Accounts.get_user!(id)
      assert user.name == @create_attrs.name
      assert user.email == @create_attrs.email
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do

    test "renders user when data is valid", %{conn: conn} do
      user = fixture(:alter_user)
      conn = put(conn, user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => id} = json_response(conn, 200)["data"]

      assert %User{} = user = Accounts.get_user!(id)
      assert user.name == @update_attrs.name
      assert user.email == @update_attrs.email
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = fixture(:alter_user)
      conn = put(conn, user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    test "deletes chosen user", %{conn: conn} do
      user = fixture(:alter_user)
      no_content_response = delete(conn, user_path(conn, :delete, user))

      assert response(no_content_response, 204)

      no_content_response = delete(conn, user_path(conn, :show, user))

      assert response(no_content_response, 204)
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
