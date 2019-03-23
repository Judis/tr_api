defmodule I18NAPIWeb.TranslationControllerTest do
  use ExUnit.Case, async: false
  @moduletag :translation_controller

  use I18NAPIWeb.ConnCase

  alias I18NAPI.Accounts
  alias I18NAPI.Projects
  alias I18NAPI.Translations
  alias I18NAPI.Translations.{Translation}
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

    if :error == result do
      with {:ok, new_user} <-
             attrs
             |> Enum.into(@user_attrs)
             |> Accounts.create_user(),
           do: new_user
    else
      user
    end
  end

  @project_attrs %{
    name: "some name",
    default_locale: "en"
  }

  def project_fixture(conn) do
    {:ok, project} =
      @project_attrs
      |> Projects.create_project(conn.user)

    project
  end

  @locale_attrs %{
    is_default: false,
    locale: "some more locale"
  }

  def locale_fixture(project) do
    {:ok, new_locale} = Translations.create_locale(@locale_attrs, project.id)
    new_locale
  end

  @valid_translation_key_attrs %{
    context: "some context",
    is_removed: false,
    key: "some key",
    default_value: "some value"
  }

  def translation_key_fixture(conn, attrs \\ %{}, project_id \\ nil) do
    project_id =
      unless is_integer(project_id) do
        project_fixture(conn).id
      else
        project_id
      end

    attrs = Enum.into(attrs, @valid_translation_key_attrs)

    {:ok, translation_key} =
      attrs
      |> Translations.create_translation_key(project_id)

    translation_key
  end

  @valid_translation_attrs %{
    value: "some translation value",
    status: :verified
  }
  @update_translation_attrs %{
    value: "some updated value",
    status: :unverified
  }
  @invalid_translation_attrs %{value: nil, status: nil}

  def translation_fixture(attrs, locale_id, translation_key_id) do
    attrs =
      %{translation_key_id: translation_key_id}
      |> Enum.into(attrs)

    {:ok, translation} =
      Translations.get_translation(translation_key_id, locale_id)
      |> Translations.update_translation(attrs)

    translation
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
    test "lists all translations", %{conn: conn} do
      project = project_fixture(conn)
      locale = Translations.get_default_locale!(project.id)
      conn = get(conn, project_locale_translation_path(conn, :index, project.id, locale.id))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create translation" do
    test "renders translation when data is valid", %{conn: conn} do
      project = project_fixture(conn)
      locale = locale_fixture(project)
      translation_key = translation_key_fixture(conn, @valid_translation_key_attrs, project.id)
      attrs = Map.put(@valid_translation_attrs, :translation_key_id, translation_key.id)

      conn =
        post(
          conn,
          project_locale_translation_path(conn, :create, project.id, locale.id),
          translation: attrs
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      result_translation = Translations.get_translation!(id)
      assert %Translation{} = result_translation
      assert result_translation.value == attrs.value
      assert result_translation.status == attrs.status
      assert result_translation.translation_key_id == attrs.translation_key_id
    end

    test "renders errors when data is invalid", %{conn: conn} do
      project = project_fixture(conn)
      locale = locale_fixture(project)
      translation_key = translation_key_fixture(conn, @valid_translation_key_attrs, project.id)
      attrs = Map.put(@invalid_translation_attrs, :translation_key_id, translation_key.id)

      conn =
        post(
          conn,
          project_locale_translation_path(conn, :create, project.id, locale.id),
          translation: attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update translation" do
    test "renders translation when data is valid", %{conn: conn} do
      project = project_fixture(conn)
      locale = locale_fixture(project)
      translation_key = translation_key_fixture(conn, @valid_translation_key_attrs, project.id)
      translation = translation_fixture(@valid_translation_attrs, locale.id, translation_key.id)
      attrs = Map.put(@update_translation_attrs, :translation_key_id, translation_key.id)

      conn =
        put(
          conn,
          project_locale_translation_path(conn, :update, project.id, locale.id, translation),
          translation: attrs
        )

      assert %{"id" => id} = json_response(conn, 200)["data"]

      result_translation = Translations.get_translation!(id)
      assert %Translation{} = result_translation
      assert result_translation.value == attrs.value
      assert result_translation.status == attrs.status
      assert result_translation.translation_key_id == attrs.translation_key_id
    end

    test "renders errors when data is invalid", %{conn: conn} do
      project = project_fixture(conn)
      locale = locale_fixture(project)
      translation_key = translation_key_fixture(conn, @valid_translation_key_attrs, project.id)
      translation = translation_fixture(@valid_translation_attrs, locale.id, translation_key.id)
      attrs = Map.put(@invalid_translation_attrs, :translation_key_id, translation_key.id)

      conn =
        put(
          conn,
          project_locale_translation_path(conn, :update, project.id, locale.id, translation),
          translation: attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete translation" do
    test "deletes chosen translation", %{conn: conn} do
      project = project_fixture(conn)
      locale = locale_fixture(project)
      translation_key = translation_key_fixture(conn, @valid_translation_key_attrs, project.id)
      translation = translation_fixture(@valid_translation_attrs, locale.id, translation_key.id)

      conn =
        delete(
          conn,
          project_locale_translation_path(conn, :delete, project.id, locale.id, translation)
        )

      assert json_response(conn, 200)["success"]
    end
  end
end
