defmodule I18NAPI.Fixtures do
  @moduledoc """
  A module for defining fixtures that can be used in tests.
  This module can be used with a list of fixtures to apply as parameter:

      use I18NAPI.Fixtures, [:user, :project]
  """
  def setup do
    alias I18NAPI.Repo

    quote do
      setup do
        Ecto.Adapters.SQL.Sandbox.checkout(I18NAPI.Repo)
        Ecto.Adapters.SQL.Sandbox.mode(I18NAPI.Repo, {:shared, self()})
        :ok
      end
    end
  end

  def setup_with_auth do
    alias I18NAPI.Repo

    quote do
      setup %{conn: conn} do
        Ecto.Adapters.SQL.Sandbox.checkout(Repo)
        Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

        user = fixture(:user)
        {:ok, jwt, _claims} = I18NAPI.Guardian.encode_and_sign(user)

        conn =
          conn
          |> put_req_header("accept", "application/json")
          |> put_req_header("authorization", "Bearer #{jwt}")
          |> Map.put(:user, user)

        {:ok, conn: conn}
      end
    end
  end

  def user do
    alias I18NAPI.Accounts
    alias I18NAPI.Accounts.User

    quote do
      @valid_user_attrs %{
        name: "valid user name",
        email: "valid_user@email.test",
        password: "Qw!23456",
        password_confirmation: "Qw!23456",
        source: "valid user source"
      }

      @valid_user_alter_attrs %{
        name: "alter user name",
        email: "alter_user@email.test",
        password: "Qw!23456",
        password_confirmation: "Qw!23456",
        source: "alter user source"
      }

      @valid_user_more_alter_attrs %{
        name: "more user name",
        email: "more_user@email.test",
        password: "Qw!23456",
        password_confirmation: "Qw!23456",
        source: "more user source"
      }
      def fixture(:user), do: fixture(:user, user: @valid_user_attrs)
      def fixture(:user_alter), do: fixture(:user, user: @valid_user_alter_attrs)
      def fixture(:user_more_alter), do: fixture(:user, user: @valid_user_more_alter_attrs)

      def fixture(:user, attrs) do
        {_, user} =
          with {:error, _} <-
                 Accounts.find_and_confirm_user(attrs[:user].email, attrs[:user].password) do
            Accounts.create_user(attrs[:user])
          end

        user
      end
    end
  end

  def project do
    alias I18NAPI.Accounts.User
    alias I18NAPI.Projects

    quote do
      @valid_project_attrs %{
        name: "some name",
        default_locale: "en"
      }

      def fixture(:project, attrs) do
        {:ok, project} =
          (attrs[:project] || @valid_project_attrs) |> Projects.create_project(attrs[:user])

        project
      end
    end
  end

  @doc """
  Apply the `fixtures`.
  """
  defmacro __using__(fixtures) when is_list(fixtures) do
    for fixture <- fixtures, is_atom(fixture), do: apply(__MODULE__, fixture, [])
  end
end
