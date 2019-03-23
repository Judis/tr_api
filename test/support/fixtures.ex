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

        user = fixture(:user_context)
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
      @user_nil %{
        confirmation_sent_at: nil,
        confirmation_token: nil,
        confirmed_at: nil,
        email: nil,
        failed_restore_attempts: nil,
        failed_sign_in_attempts: nil,
        is_confirmed: nil,
        last_visited_at: nil,
        name: nil,
        password_hash: nil,
        restore_accepted_at: nil,
        restore_requested_at: nil,
        restore_token: nil,
        source: nil
      }
      def attrs(:user_nil), do: @user_nil

      @user_context %{
        name: "context user name",
        email: "context_user@email.test",
        password: "Qw!23456",
        password_confirmation: "Qw!23456",
        source: "context user source"
      }
      def attrs(:user_context), do: @user_context

      @user_valid %{
        name: "valid user name",
        email: "valid_user@email.test",
        password: "Qw!23456",
        password_confirmation: "Qw!23456",
        source: "valid user source"
      }
      def attrs(:user), do: @user_valid

      @user_alter %{
        name: "alter user name",
        email: "alter_user@email.test",
        password: "Qw!23456",
        password_confirmation: "Qw!23456",
        source: "alter user source"
      }
      def attrs(:user_alter), do: @user_alter

      @user_more_alter %{
        name: "more user name",
        email: "more_user@email.test",
        password: "Qw!23456",
        password_confirmation: "Qw!23456",
        source: "more user source"
      }
      def attrs(:user_more_alter), do: @user_more_alter

      def fixture(:user), do: fixture(:user, user: @user_valid)
      def fixture(:user_alter), do: fixture(:user, user: @user_alter)
      def fixture(:user_more_alter), do: fixture(:user, user: @user_more_alter)
      def fixture(:user_nil), do: fixture(:user, user: @user_nil)
      def fixture(:user_context), do: fixture(:user, user: @user_context)

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
      @project_alter_attrs %{name: "alter name", default_locale: "en"}
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
    alias I18NAPI.Projects.{Project, UserRole}

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
               Projects.get_user_role!(attrs.project_id, attrs.user_id) do
          Projects.create_user_role(attrs)
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

  def user_locale do
    alias I18NAPI.Projects.Project
    alias I18NAPI.Translations
    alias I18NAPI.Translations.UserLocale

    quote do
      @user_locale %{role: 0}
      def attrs(:user_locale), do: @user_locale
      @user_locale_alter %{role: 1}
      def attrs(:user_locale_alter), do: @user_locale_alter
      @user_locale_invalid %{role: :abrakadabra}
      def attrs(:user_locale_invalid), do: @user_locale_invalid
      @user_locale_nil %{role: nil}
      def attrs(:user_locale_nil), do: @user_locale_nil

      def fixture(:user_locale, user_locale: attrs) do
        ul = Translations.get_user_locale(attrs.locale_id, attrs.user_id)

        case is_nil(ul) do
          true ->
            {:ok, new_ul} = Translations.create_user_locale(attrs)
            new_ul

          false ->
            ul
        end
      end

      def fixture(:user_locale, %{user_id: _, locale_id: _} = attrs) do
        attrs = @user_locale |> Map.merge(attrs)
        fixture(:user_locale, user_locale: attrs)
      end

      def fixture(:user_locale_alter, %{user_id: _, locale_id: _} = attrs) do
        attrs = @user_locale_alter |> Map.merge(attrs)
        fixture(:user_locale, user_locale: attrs)
      end

      def fixture(:user_locale_invalid, %{user_id: _, locale_id: _} = attrs) do
        attrs = @user_locale_invalid |> Map.merge(attrs)
        fixture(:user_locale, user_locale: attrs)
      end

      def fixture(:user_locale_nil, %{user_id: _, locale_id: _} = attrs) do
        attrs = @user_locale_nil |> Map.merge(attrs)
        fixture(:user_locale, user_locale: attrs)
      end
    end
  end

  def locale do
    alias I18NAPI.Translations
    alias I18NAPI.Translations.Locale

    quote do
      @locale %{
        locale: "some locale",
        status: 0,
        is_default: true
      }
      def attrs(:locale), do: @locale

      @locale_alter %{
        locale: "some updated locale",
        status: 1,
        is_default: false
      }
      def attrs(:locale_alter), do: @locale_alter

      @locale_invalid %{
        locale: "some updated locale",
        status: "bad status",
        is_default: false
      }
      def attrs(:locale_invalid), do: @locale_invalid

      @locale_nil %{
        locale: nil,
        status: nil,
        is_default: nil
      }
      def attrs(:locale_nil), do: @locale_nil

      def fixture(:locale, locale: attrs) do
        attrs = attrs || @locale

        with %Locale{} <-
               locale =
                 Translations.get_locale_by_name_and_project(attrs.locale, attrs.project_id) do
          locale
        else
          _ ->
            {:ok, locale} = attrs |> Translations.create_locale(attrs.project_id)
            locale
        end
      end

      def fixture(:locale, %{project_id: _} = attrs) do
        attrs = @locale |> Map.merge(attrs)
        fixture(:locale, locale: attrs)
      end

      def fixture(:locale_alter, %{project_id: _} = attrs) do
        attrs = @locale_alter |> Map.merge(attrs)
        fixture(:locale, locale: attrs)
      end

      def fixture(:locale_invalid, %{project_id: _} = attrs) do
        attrs = @locale_invalid |> Map.merge(attrs)
        fixture(:locale, locale: attrs)
      end

      def fixture(:locale_nil, %{project_id: _} = attrs) do
        attrs = @locale_nil |> Map.merge(attrs)
        fixture(:locale, locale: attrs)
      end
    end
  end

  def invitation do
    alias I18NAPI.Accounts
    alias I18NAPI.Projects
    alias I18NAPI.Projects.{Invite, Invitation}

    quote do
      @invite %{
        name: "some name",
        email: "some_email@email.test",
        message: "some message",
        role: :translator,
        is_removed: false,
        token: "1234567890qwertyopASDF"
      }
      def attrs(:invite), do: @invite

      @invite_alter %{
        name: "some name",
        email: "some_email@email.test",
        message: "alter message",
        role: :translator,
        is_removed: false,
        token: "1234567890qwertyopASDF"
      }
      def attrs(:invite_alter), do: @invite_alter

      @invite_invalid %{
        name: "some name",
        email: "some_email@email.test",
        message: "some message",
        role: :translator,
        is_removed: false,
        token: "1234567890qwertyopASDF"
      }
      def attrs(:invite_invalid), do: @invite_invalid

      @invite_nil %{
        name: "some name",
        email: "some_email@email.test",
        message: nil,
        role: :translator,
        is_removed: false,
        token: "1234567890qwertyopASDF"
      }
      def attrs(:invite_nil), do: @invite_nil

      def fixture(:invite, invite: attrs) do
        recipient = Accounts.get_user(attrs[:recipient_id])
        inviter = Accounts.get_user(attrs[:inviter_id])
        new_project = Projects.get_project(attrs[:project_id])

        {:ok, new_invite} = Projects.create_invite(attrs)

        invite_link = Invitation.create_invitation_project_link(new_project.id, new_invite.token)

        Invitation.create_link_and_send_email_for_not_confirmed_user(
          {:ok, new_invite},
          recipient,
          inviter,
          new_project
        )

        {:ok, new_invite} = Projects.update_field_invited_at(new_invite)
        new_invite
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

  def translation_key do
    alias I18NAPI.Projects
    alias I18NAPI.Projects.{Project}
    alias I18NAPI.Translations
    alias I18NAPI.Translations.{TranslationKey}

    quote do
      @translation_key_valid %{
        context: "some context",
        is_removed: false,
        key: "some key",
        default_value: "some value"
      }
      def attrs(:translation_key), do: @translation_key_valid

      @translation_key_alter %{
        context: "some updated context",
        is_removed: false,
        key: "some updated key",
        default_value: "some updated value"
      }
      def attrs(:translation_key_alter), do: @translation_key_alter

      @translation_key_nil %{
        context: nil,
        is_removed: nil,
        key: nil,
        removed_at: nil,
        default_value: nil
      }
      def attrs(:translation_key_nil), do: @translation_key_nil

      def fixture(:translation_key, translation_key: attrs) do
        {:ok, translation_key} =
          (attrs || @translation_key_valid)
          |> Translations.create_translation_key(attrs.project_id)

        translation_key
      end

      def fixture(:translation_key, %{project_id: _} = attrs) do
        attrs = @translation_key_valid |> Map.merge(attrs)
        fixture(:translation_key, translation_key: attrs)
      end

      def fixture(:translation_key_alter, %{project_id: _} = attrs) do
        attrs = @translation_key_alter |> Map.merge(attrs)
        fixture(:translation_key, translation_key: attrs)
      end

      def fixture(:translation_key_nil, %{project_id: _} = attrs) do
        attrs = @translation_key_nil |> Map.merge(attrs)
        fixture(:translation_key, translation_key: attrs)
      end
    end
  end

  def import_locale do
    quote do
      @import_locale_valid %{"a_key" => "a_value", "b_key" => "b_value"}
      def attrs(:import_locale_valid), do: @import_locale_valid
    end
  end

  @doc """
  Apply the `fixtures`.
  """
  defmacro __using__(fixtures) when is_list(fixtures) do
    for fixture <- fixtures, is_atom(fixture), do: apply(__MODULE__, fixture, [])
  end
end
