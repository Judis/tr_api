defmodule I18NAPIWeb.LocaleControllerTest do
  use I18NAPIWeb.ConnCase

  alias I18NAPI.Translations
  alias I18NAPI.Translations.Locale

  @create_attrs %{
    count_of_keys: 42,
    count_of_translated_keys: 42,
    count_of_words: 42,
    is_default: true,
    is_removed: true,
    locale: "some locale",
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
    {:ok, locale} = Translations.create_locale(@create_attrs)
    locale
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all locales", %{conn: conn} do
      conn = get(conn, locale_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create locale" do
    test "renders locale when data is valid", %{conn: conn} do
      conn = post(conn, locale_path(conn, :create), locale: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, locale_path(conn, :show, id))

      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "count_of_keys" => 42,
               "count_of_translated_keys" => 42,
               "count_of_words" => 42,
               "is_default" => true,
               "is_removed" => true,
               "locale" => "some locale",
               "removed_at" => ~N[2010-04-17 14:00:00.000000]
             }
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, locale_path(conn, :create), locale: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update locale" do
    setup [:create_locale]

    test "renders locale when data is valid", %{conn: conn, locale: %Locale{id: id} = locale} do
      conn = put(conn, locale_path(conn, :update, locale), locale: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, locale_path(conn, :show, id))

      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "count_of_keys" => 43,
               "count_of_translated_keys" => 43,
               "count_of_words" => 43,
               "is_default" => false,
               "is_removed" => false,
               "locale" => "some updated locale",
               "removed_at" => ~N[2011-05-18 15:01:01.000000]
             }
    end

    test "renders errors when data is invalid", %{conn: conn, locale: locale} do
      conn = put(conn, locale_path(conn, :update, locale), locale: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete locale" do
    setup [:create_locale]

    test "deletes chosen locale", %{conn: conn, locale: locale} do
      conn = delete(conn, locale_path(conn, :delete, locale))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, locale_path(conn, :show, locale))
      end)
    end
  end

  defp create_locale(_) do
    locale = fixture(:locale)
    {:ok, locale: locale}
  end
end
