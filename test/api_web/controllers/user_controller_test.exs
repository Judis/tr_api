defmodule I18NAPIWeb.UserControllerTest do
  use ExUnit.Case, async: true
  @moduletag :user_controller

  use I18NAPIWeb.ConnCase
  use I18NAPI.Fixtures, [:setup_with_auth, :user]

  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, user_path(conn, :index))
      [result | _] = json_response(conn, 200)["data"]
      assert result["name"] == attrs(:user_context).name
      assert result["email"] == attrs(:user_context).email
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, user_path(conn, :create), user: attrs(:user))
      assert %{"id" => id} = json_response(conn, 201)["data"]

      assert %User{} = user = Accounts.get_user!(id)
      assert user.name == attrs(:user).name
      assert user.email == attrs(:user).email
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, user_path(conn, :create), user: attrs(:user_nil))
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:user]

    test "renders user when data is valid", %{conn: conn, user: user} do
      conn = put(conn, user_path(conn, :update, user), user: attrs(:user))
      assert %{"id" => id} = json_response(conn, 200)["data"]

      assert %User{} = user = Accounts.get_user!(id)
      assert user.name == attrs(:user).name
      assert user.email == attrs(:user).email
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, user_path(conn, :update, user), user: attrs(:user_nil))
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:user]

    test "deletes chosen user", %{conn: conn, user: user} do
      no_content_response = delete(conn, user_path(conn, :delete, user))
      assert json_response(no_content_response, 200)["success"]

      no_content_response = get(conn, user_path(conn, :show, user))
      assert response(no_content_response, 204)
    end
  end

  defp user(%{conn: _}), do: {:ok, user: fixture(:user)}
end
