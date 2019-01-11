defmodule I18NAPIWeb.UserLocalesControllerTest do
  use I18NAPIWeb.ConnCase

  alias I18NAPI.Projects
  alias I18NAPI.Projects.UserLocales

  @create_attrs %{role: 42}
  @update_attrs %{role: 43}
  @invalid_attrs %{role: nil}

  def fixture(:user_locales) do
    {:ok, user_locales} = Projects.create_user_locales(@create_attrs)
    user_locales
  end

  @user_attrs %{
    name: "test name",
    email: "test@email.test",
    password: "Qw!23456",
    password_confirmation: "Qw!23456",
    source: "test source"
  }

  def user_fixture(attrs \\ %{}) do
    {result, user} = Accounts.find_and_confirm_user(@user_attrs.email, @user_attrs.password)

    if :error == result do
      with {:ok, new_user} <- attrs |> Enum.into(@user_attrs) |> Accounts.create_user(),
           do: new_user
    else
      user
    end
  end

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.checkout(I18NAPI.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(I18NAPI.Repo, {:shared, self()})

    user = user_fixture()
    {:ok, jwt, _claims} = I18NAPI.Guardian.encode_and_sign(user)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{jwt}")
      |> Map.put(:user, user)

    {:ok, conn: conn}
  end

  describe "index" do
    test "lists all user_locales", %{conn: conn} do
      conn = get(conn, user_locales_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user_locales" do
    test "renders user_locales when data is valid", %{conn: conn} do
      conn = post(conn, user_locales_path(conn, :create), user_locales: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, user_locales_path(conn, :show, id))
      assert json_response(conn, 200)["data"] == %{"id" => id, "role" => 42}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, user_locales_path(conn, :create), user_locales: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user_locales" do
    setup [:create_user_locales]

    test "renders user_locales when data is valid", %{
      conn: conn,
      user_locales: %UserLocales{id: id} = user_locales
    } do
      conn =
        put(conn, user_locales_path(conn, :update, user_locales), user_locales: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, user_locales_path(conn, :show, id))
      assert json_response(conn, 200)["data"] == %{"id" => id, "role" => 43}
    end

    test "renders errors when data is invalid", %{conn: conn, user_locales: user_locales} do
      conn =
        put(conn, user_locales_path(conn, :update, user_locales), user_locales: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user_locales" do
    setup [:create_user_locales]

    test "deletes chosen user_locales", %{conn: conn, user_locales: user_locales} do
      conn = delete(conn, user_locales_path(conn, :delete, user_locales))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, user_locales_path(conn, :show, user_locales))
      end)
    end
  end

  defp create_user_locales(_) do
    user_locales = fixture(:user_locales)
    {:ok, user_locales: user_locales}
  end
end
