defmodule I18NAPIWeb.LocaleControllerTest do
  use ExUnit.Case, async: true
  @moduletag :locale_controller

  use I18NAPIWeb.ConnCase

  alias I18NAPI.Translations
  alias I18NAPI.Translations.Locale
  alias I18NAPI.Projects
  alias I18NAPI.Accounts
  import Ecto.Query, warn: false

  @user_attrs %{
    name: "test name",
    email: "test@email.test",
    password: "Qw!23456",
    password_confirmation: "Qw!23456",
    source: "test source"
  }

  def user_fixture(attrs \\ %{}) do
    {result, user} = Accounts.find_and_confirm_user(@user_attrs.email, @user_attrs.password)
    if (:error == result) do
      with {:ok, new_user} <- attrs |> Enum.into(@user_attrs) |> Accounts.create_user(),
           do: new_user
    else
      user
    end
  end

  @valid_project_attrs %{
    name: "some name",
    default_locale: "en"
  }
  
  def project_fixture(conn) do
    {:ok, project} = @valid_project_attrs |> Projects.create_project(conn.user)
    project
  end

  setup %{conn: conn} do
    user = user_fixture()
    {:ok, jwt, _claims} = I18NAPI.Guardian.encode_and_sign(user)
    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{jwt}")
      |> Map.put(:user, user)

    {:ok, conn: conn}
  end

  @create_attrs %{
    is_default: true,
    locale: "some locale",
  }

  @valid_attrs %{
    is_default: true,
    locale: "another locale",
  }

  @update_attrs %{
    is_default: false,
    locale: "some updated locale",
  }
  @invalid_attrs %{
    is_default: nil,
    is_removed: nil,
    locale: nil,
  }

  def locale_fixture(project) do
    default_locale = Translations.get_default_locale!(project.id)

    if nil == default_locale do
      {:ok, new_locale} = Translations.create_locale(@create_attrs, project.id)
      new_locale
    else
      default_locale
    end
  end

  describe "index" do
    test "lists all locales", %{conn: conn} do
      project = project_fixture(conn)
      conn = get(conn, project_locale_path(conn, :index, project.id))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create locale" do
    test "renders locale when data is valid", %{conn: conn} do
      project_id = project_fixture(conn).id
      conn = post(conn, project_locale_path(conn, :create, project_id), locale: @valid_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      result_locale = Translations.get_locale!(id)
      assert %Locale{} = result_locale
      assert result_locale.locale == @valid_attrs.locale
      assert result_locale.is_default == @valid_attrs.is_default
    end

    test "renders errors when data is invalid", %{conn: conn} do
      project = project_fixture(conn)
      locale = locale_fixture(project)
      conn = post(conn, project_locale_path(conn, :create, locale.project_id), locale: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update locale" do
    test "renders locale when data is valid", %{conn: conn} do
      project = project_fixture(conn)
      locale = locale_fixture(project)
      project_id = project.id
      conn = put(conn, project_locale_path(conn, :update, project_id, locale), locale: @update_attrs)
      assert %{"id" => id} = json_response(conn, 200)["data"]

      result_locale = Translations.get_locale!(locale.id)
      assert result_locale.locale == @update_attrs.locale
    end

    test "renders errors when data is invalid", %{conn: conn} do
      project = project_fixture(conn)
      locale = locale_fixture(project)
      conn = put(conn, project_locale_path(conn, :update, locale.project_id, locale), locale: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete locale" do
    test "deletes chosen locale", %{conn: conn} do
      project = project_fixture(conn)
      locale = locale_fixture(project)
      no_content_response = delete(conn, project_locale_path(conn, :delete, locale.project_id, locale))

      assert response(no_content_response, 204)

      no_content_response = delete(conn, project_locale_path(conn, :show, locale.project_id, locale))

      assert response(no_content_response, 204)
    end
  end
end
