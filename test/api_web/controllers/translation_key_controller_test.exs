defmodule I18NAPIWeb.TranslationKeyControllerTest do
  use ExUnit.Case, async: false
  @moduletag :translation_key_controller

  use I18NAPIWeb.ConnCase

  alias I18NAPI.Accounts
  alias I18NAPI.Projects
  alias I18NAPI.Translations
  alias I18NAPI.Translations.{TranslationKey}

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
      with {:ok, new_user} <- attrs |> Enum.into(@user_attrs) |> Accounts.create_user(),
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
    {:ok, project} = @project_attrs |> Projects.create_project(conn.user)
    project
  end

  @valid_translation_key_attrs %{
    context: "some context",
    is_removed: false,
    key: "some key",
    default_value: "some value"
  }

  @update_translation_key_attrs %{
    context: "some updated context",
    is_removed: false,
    key: "some updated key",
    default_value: "some updated value"
  }

  @invalid_translation_key_attrs %{
    context: nil,
    is_removed: nil,
    key: nil,
    removed_at: nil,
    default_value: nil
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
    test "lists all translation_keys", %{conn: conn} do
      project = project_fixture(conn)
      conn = get(conn, project_translation_key_path(conn, :index, project.id))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create translation_key" do
    test "renders translation_key when data is valid", %{conn: conn} do
      project_id = project_fixture(conn).id

      conn =
        post(conn, project_translation_key_path(conn, :create, project_id),
          translation_key: @valid_translation_key_attrs
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      result_key = Translations.get_translation_key!(id)
      assert %TranslationKey{} = result_key
      assert result_key.key == @valid_translation_key_attrs.key
      assert result_key.default_value == @valid_translation_key_attrs.default_value
      assert result_key.context == @valid_translation_key_attrs.context
      assert result_key.is_removed == @valid_translation_key_attrs.is_removed
    end

    test "renders errors when data is invalid", %{conn: conn} do
      project_id = project_fixture(conn).id

      conn =
        post(conn, project_translation_key_path(conn, :create, project_id),
          translation_key: @invalid_translation_key_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update translation_key" do
    test "renders translation_key when data is valid", %{conn: conn} do
      project_id = project_fixture(conn).id
      translation_key = translation_key_fixture(conn, @valid_translation_key_attrs, project_id)

      conn =
        put(conn, project_translation_key_path(conn, :update, project_id, translation_key),
          translation_key: @update_translation_key_attrs
        )

      assert %{"id" => id} = json_response(conn, 200)["data"]

      result_key = Translations.get_translation_key!(id)
      assert %TranslationKey{} = result_key
      assert result_key.key == @update_translation_key_attrs.key
      assert result_key.default_value == @update_translation_key_attrs.default_value
      assert result_key.context == @update_translation_key_attrs.context
      assert result_key.is_removed == @update_translation_key_attrs.is_removed
    end

    test "renders errors when data is invalid", %{conn: conn} do
      project_id = project_fixture(conn).id
      translation_key = translation_key_fixture(conn, @valid_translation_key_attrs, project_id)

      conn =
        put(conn, project_translation_key_path(conn, :update, project_id, translation_key),
          translation_key: @invalid_translation_key_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete translation_key" do
    test "deletes chosen translation_key", %{conn: conn} do
      project_id = project_fixture(conn).id
      translation_key = translation_key_fixture(conn, @valid_translation_key_attrs, project_id)

      no_content_response =
        delete(
          conn,
          project_translation_key_path(conn, :delete, translation_key.project_id, translation_key)
        )

      assert response(no_content_response, 204)

      no_content_response =
        delete(
          conn,
          project_translation_key_path(conn, :show, translation_key.project_id, translation_key)
        )

      assert response(no_content_response, 204)
    end
  end
end
