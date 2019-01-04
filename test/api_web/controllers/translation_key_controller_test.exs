defmodule I18NAPIWeb.TranslationKeyControllerTest do
  use I18NAPIWeb.ConnCase

  alias I18NAPI.Accounts
  alias I18NAPI.Projects
  alias I18NAPI.Translations
  alias I18NAPI.Translations.{Locale, TranslationKey}

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

  @locale_attrs %{
    is_default: true,
    locale: "some locale"
  }

  def locale_fixture(project) do
    default_locale = Translations.get_default_locale!(project.id)

    if nil == default_locale do
      {:ok, new_locale} = Translations.create_locale(@locale_attrs, project.id)
      new_locale
    else
      default_locale
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
    test "lists all translation_keys", %{conn: conn} do
      assert false
    end
  end

  describe "create translation_key" do
    test "renders translation_key when data is valid", %{conn: conn} do
      assert false
    end

    test "renders errors when data is invalid", %{conn: conn} do
      assert false
    end
  end

  describe "update translation_key" do
    test "renders translation_key when data is valid", %{conn: conn} do
      assert false
    end

    test "renders errors when data is invalid", %{conn: conn} do
      assert false
    end
  end

  describe "delete translation_key" do
    test "deletes chosen translation_key", %{conn: conn} do
      assert false
    end
  end
end
