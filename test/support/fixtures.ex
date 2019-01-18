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
      def attrs(:user), do: @valid_user_attrs

      @valid_user_alter_attrs %{
        name: "alter user name",
        email: "alter_user@email.test",
        password: "Qw!23456",
        password_confirmation: "Qw!23456",
        source: "alter user source"
      }
      def attrs(:user_alter), do: @valid_user_attrs

      @valid_user_more_alter_attrs %{
        name: "more user name",
        email: "more_user@email.test",
        password: "Qw!23456",
        password_confirmation: "Qw!23456",
        source: "more user source"
      }
      def attrs(:user_more_alter), do: @valid_user_more_alter_attrs

      def fixture(:user), do: fixture(:user, user: @valid_user_attrs)
      def fixture(:user_alter), do: fixture(:user, user: @valid_user_alter_attrs)
      def fixture(:user_more_alter), do: fixture(:user, user: @valid_user_more_alter_attrs)

      def fixture(:user, user: attrs) do
        {_, user} =
          with {:error, _} <-
                 Accounts.find_and_confirm_user(attrs.email, attrs.password) do
            Accounts.create_user(attrs)
          end

        user
      end
    end
  end

  def project do
    alias I18NAPI.Accounts.User
    alias I18NAPI.Projects

    quote do
      @project_valid_attrs %{name: "some name", default_locale: "en"}
      def attrs(:project), do: @project_valid_attrs
      @project_alter_attrs %{name: "alter name"}
      def attrs(:project_alter), do: @project_alter_attrs
      @project_nil_attrs %{name: nil, default_locale: nil, is_removed: nil, removed_at: nil}
      def attrs(:project_nil), do: @project_nil_attrs

      def fixture(:project, attrs) do
        {:ok, project} =
          (attrs[:project] || @project_valid_attrs) |> Projects.create_project(attrs[:user])

        project
      end
    end
  end

  def user_role do
    alias I18NAPI.Projects
    alias I18NAPI.Projects.{Project, UserRoles}

    quote do
      @user_role_admin %{role: :admin}
      def attrs(:user_role), do: @user_role_admin
      @user_role_manager %{role: :manager}
      def attrs(:user_role_manager), do: @user_role_manager
      @user_role_translator %{role: :translator}
      def attrs(:user_role_translator), do: @user_role_translator
      @user_role_invalid %{role: :abrakadabra}
      def attrs(:user_role_invalid), do: @user_role_invalid
      @user_role_nil %{role: nil}
      def attrs(:user_role_nil), do: @user_role_nil

      def fixture(:user_role, user_role: attrs) do
        with {:error, _} <-
               Projects.get_user_roles!(attrs.project_id, attrs.user_id) do
          Projects.create_user_roles(attrs)
        end
      end

      def fixture(:user_role, %{user_id: _, project_id: _} = attrs) do
        attrs = @user_role_admin |> Map.merge(attrs)
        fixture(:user_role, user_role: attrs)
      end

      def fixture(:user_role_manager, %{user_id: _, project_id: _} = attrs) do
        attrs = @user_role_manager |> Map.merge(attrs)
        fixture(:user_role, user_role: attrs)
      end

      def fixture(:user_role_translator, %{user_id: _, project_id: _} = attrs) do
        attrs = @user_role_translator |> Map.merge(attrs)
        fixture(:user_role, user_role: attrs)
      end

      def fixture(:user_role_invalid, %{user_id: _, project_id: _} = attrs) do
        attrs = @user_role_invalid |> Map.merge(attrs)
        fixture(:user_role, user_role: attrs)
      end

      def fixture(:user_role_nil, %{user_id: _, project_id: _} = attrs) do
        attrs = @user_role_nil |> Map.merge(attrs)
        fixture(:user_role, user_role: attrs)
      end
    end
  end

  def invite do
    alias I18NAPI.Projects
    alias I18NAPI.Projects.{Invite, Project}

    quote do
      @invite %{
        message: "some message",
        role: :translator,
        is_removed: false,
        token: "1234567890qwertyopASDF"
      }
      def attrs(:invite), do: @invite

      @invite_alter %{
        message: "alter message",
        role: :translator,
        is_removed: false,
        token: "1234567890qwertyopASDF"
      }
      def attrs(:invite_alter), do: @invite_alter

      @invite_invalid %{
        message: "some message",
        role: :translator,
        is_removed: false,
        token: "1234567890qwertyopASDF"
      }
      def attrs(:invite_invalid), do: @invite_invalid

      @invite_nil %{
        message: nil,
        role: :translator,
        is_removed: false,
        token: "1234567890qwertyopASDF"
      }
      def attrs(:invite_nil), do: @invite_nil

      def fixture(:invite, invite: attrs) do
          Projects.create_invite(attrs)
      end

      def fixture(:invite, %{inviter_id: _, recipient_id: _, project_id: _} = attrs) do
        attrs = @invite |> Map.merge(attrs)
        fixture(:invite, invite: attrs)
      end

      def fixture(:invite_alter, %{inviter_id: _, recipient_id: _, project_id: _} = attrs) do
        attrs = @invite_alter |> Map.merge(attrs)
        fixture(:invite, invite: attrs)
      end

      def fixture(:invite_invalid, %{inviter_id: _, recipient_id: _, project_id: _} = attrs) do
        attrs = @invite_invalid |> Map.merge(attrs)
        fixture(:invite, invite: attrs)
      end

      def fixture(:invite_nil, %{inviter_id: _, recipient_id: _, project_id: _} = attrs) do
        attrs = @invite_nil |> Map.merge(attrs)
        fixture(:invite, invite: attrs)
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
