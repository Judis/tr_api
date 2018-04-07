defmodule I18NAPIWeb.UserControllerTest do
  use I18NAPIWeb.ConnCase

  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User

  @create_attrs %{confirmation_sent_at: ~N[2010-04-17 14:00:00.000000], confirmation_token: "some confirmation_token", confirmed_at: ~N[2010-04-17 14:00:00.000000], email: "some email", failed_restore_attempts: 42, failed_sign_in_attempts: 42, invited_at: ~N[2010-04-17 14:00:00.000000], is_confirmed: true, last_visited_at: ~N[2010-04-17 14:00:00.000000], name: "some name", password_hash: "some password_hash", restore_accepted_at: ~N[2010-04-17 14:00:00.000000], restore_requested_at: ~N[2010-04-17 14:00:00.000000], restore_token: "some restore_token", source: "some source"}
  @update_attrs %{confirmation_sent_at: ~N[2011-05-18 15:01:01.000000], confirmation_token: "some updated confirmation_token", confirmed_at: ~N[2011-05-18 15:01:01.000000], email: "some updated email", failed_restore_attempts: 43, failed_sign_in_attempts: 43, invited_at: ~N[2011-05-18 15:01:01.000000], is_confirmed: false, last_visited_at: ~N[2011-05-18 15:01:01.000000], name: "some updated name", password_hash: "some updated password_hash", restore_accepted_at: ~N[2011-05-18 15:01:01.000000], restore_requested_at: ~N[2011-05-18 15:01:01.000000], restore_token: "some updated restore_token", source: "some updated source"}
  @invalid_attrs %{confirmation_sent_at: nil, confirmation_token: nil, confirmed_at: nil, email: nil, failed_restore_attempts: nil, failed_sign_in_attempts: nil, invited_at: nil, is_confirmed: nil, last_visited_at: nil, name: nil, password_hash: nil, restore_accepted_at: nil, restore_requested_at: nil, restore_token: nil, source: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get conn, user_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, user_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "confirmation_sent_at" => ~N[2010-04-17 14:00:00.000000],
        "confirmation_token" => "some confirmation_token",
        "confirmed_at" => ~N[2010-04-17 14:00:00.000000],
        "email" => "some email",
        "failed_restore_attempts" => 42,
        "failed_sign_in_attempts" => 42,
        "invited_at" => ~N[2010-04-17 14:00:00.000000],
        "is_confirmed" => true,
        "last_visited_at" => ~N[2010-04-17 14:00:00.000000],
        "name" => "some name",
        "password_hash" => "some password_hash",
        "restore_accepted_at" => ~N[2010-04-17 14:00:00.000000],
        "restore_requested_at" => ~N[2010-04-17 14:00:00.000000],
        "restore_token" => "some restore_token",
        "source" => "some source"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put conn, user_path(conn, :update, user), user: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, user_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "confirmation_sent_at" => ~N[2011-05-18 15:01:01.000000],
        "confirmation_token" => "some updated confirmation_token",
        "confirmed_at" => ~N[2011-05-18 15:01:01.000000],
        "email" => "some updated email",
        "failed_restore_attempts" => 43,
        "failed_sign_in_attempts" => 43,
        "invited_at" => ~N[2011-05-18 15:01:01.000000],
        "is_confirmed" => false,
        "last_visited_at" => ~N[2011-05-18 15:01:01.000000],
        "name" => "some updated name",
        "password_hash" => "some updated password_hash",
        "restore_accepted_at" => ~N[2011-05-18 15:01:01.000000],
        "restore_requested_at" => ~N[2011-05-18 15:01:01.000000],
        "restore_token" => "some updated restore_token",
        "source" => "some updated source"}
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete conn, user_path(conn, :delete, user)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, user_path(conn, :show, user)
      end
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
