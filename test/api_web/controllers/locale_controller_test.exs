defmodule I18NAPIWeb.LocaleControllerTest do
  use ExUnit.Case, async: true
  @moduletag :locale_controller

  use I18NAPIWeb.ConnCase

  alias I18NAPI.Translations
  alias I18NAPI.Translations.Locale
  alias I18NAPI.Projects
  alias I18NAPI.Projects.Project
  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User
  import Ecto.Query, warn: false
  alias I18NAPI.Repo

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
      {:ok, user} =
        attrs
        |> Enum.into(@user_attrs)
        |> Accounts.create_user()
    end

    user
  end

  @valid_project_attrs %{
    name: "some name",
    default_locale: "en"
  }

  def project_fixture(attrs \\ %{}, %User{} = user) do
    {:ok, project} =
      attrs
      |> Enum.into(@valid_project_attrs)
      |> Projects.create_project(user)

    project
  end

  setup %{conn: conn} do
    user = user_fixture()
      {:ok, jwt, _claims} = I18NAPI.Guardian.encode_and_sign(user)
    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{jwt}")

    {:ok, conn: conn}
  end

  @create_attrs %{
    count_of_keys: 42,
    count_of_translated_keys: 42,
    count_of_words: 42,
    is_default: true,
    is_removed: true,
    locale: "some locale",
    removed_at: ~N[2010-04-17 14:00:00.000000]
  }

  @valid_attrs %{
    count_of_keys: 42,
    count_of_translated_keys: 42,
    count_of_words: 42,
    is_default: true,
    is_removed: true,
    locale: "another locale",
    removed_at: ~N[2010-04-17 14:00:00.000000]
  }

  @update_attrs %{
    count_of_keys: 43,
    count_of_translated_keys: 43,
    count_of_words: 43,
    is_default: false,
    is_removed: false,
    locale: "some updated locale",
    removed_at: ~N[2011-05-18 15:01:01.000000]
  }
  @invalid_attrs %{
    count_of_keys: nil,
    count_of_translated_keys: nil,
    count_of_words: nil,
    is_default: nil,
    is_removed: nil,
    locale: nil,
    removed_at: nil
  }

  def fixture(:locale) do
    user = user_fixture()
    project_id = project_fixture(@valid_project_attrs, user).id
    query = from(
      p in Locale,
      select: p,
      where: p.project_id == ^project_id and p.locale == ^@create_attrs.locale
    )
    result = Repo.one(query)

    if nil == result do
      result = Translations.create_locale(@create_attrs, project_id)
    end

    {:ok, locale} = result
    locale
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all locales", %{conn: conn} do
      locale = fixture( :locale)
      conn = get(conn, project_locale_path(conn, :index, locale.project_id, locale))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create locale" do
    test "renders locale when data is valid", %{conn: conn} do
      project_id = fixture(:locale).project_id
      conn = post(conn, project_locale_path(conn, :create, project_id), locale: @valid_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]
      query = from(
        p in Locale,
        select: p,
        where: p.project_id == ^project_id and p.locale == ^@valid_attrs.locale
      )
      result_locale = Repo.one(query)
      assert result_locale.locale == @valid_attrs.locale

#      conn = get(conn, project_locale_path(conn, :show, locale.project_id, id))

#      assert json_response(conn, 200)["data"] == %{
#               "id" => id,
#               "count_of_keys" => 42,
#               "count_of_translated_keys" => 42,
#               "count_of_words" => 42,
#               "is_default" => true,
#               "is_removed" => true,
#               "locale" => "another locale",
#               "removed_at" => ~N[2010-04-17 14:00:00.000000]
#             }
    end

    test "renders errors when data is invalid", %{conn: conn} do
      locale = fixture( :locale)
      conn = post(conn, project_locale_path(conn, :create, locale.project_id), locale: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update locale" do
    setup [:create_locale]

    test "renders locale when data is valid", %{conn: conn, locale: %Locale{id: id} = locale} do
      project_id = locale.project_id
      conn = put(conn, project_locale_path(conn, :update, project_id, locale), locale: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      query = from(
        p in Locale,
        select: p,
        where: p.project_id == ^project_id and p.locale == ^@update_attrs.locale
      )
      result_locale = Repo.one(query)
      assert result_locale.locale == @update_attrs.locale

#      conn = get(conn, project_locale_path(conn, :show, locale.project_id, id))

#      assert json_response(conn, 200)["data"] == %{
#               "id" => id,
#               "count_of_keys" => 43,
#               "count_of_translated_keys" => 43,
#               "count_of_words" => 43,
#               "is_default" => false,
#               "is_removed" => false,
#               "locale" => "some updated locale",
#               "removed_at" => ~N[2011-05-18 15:01:01.000000]
#             }
    end

    test "renders errors when data is invalid", %{conn: conn, locale: locale} do
      conn = put(conn, project_locale_path(conn, :update, locale.project_id, locale), locale: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete locale" do
    setup [:create_locale]

    test "deletes chosen locale", %{conn: conn, locale: locale} do
      result = delete(conn, project_locale_path(conn, :delete, locale.project_id, locale))
      assert response(result, 200)

      project_id = locale.project_id
      query = from(
        p in Locale,
        select: p,
        where: p.project_id == ^project_id and p.locale == ^@create_attrs.locale
      )
      result_locale = Repo.one(query)
      assert result_locale.locale == @create_attrs.locale

      assert_error_sent(404, fn ->
        get(conn, project_locale_path(conn, :show, locale.project_id, locale))
      end)
    end
  end

  defp create_locale(_) do
    locale = fixture(:locale)
    {:ok, locale: locale}
  end
end
