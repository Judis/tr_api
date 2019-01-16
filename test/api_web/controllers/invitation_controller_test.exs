defmodule I18NAPIWeb.InvitationControllerTest do
  use ExUnit.Case, async: true
  @moduletag :invitation_controller

  use I18NAPIWeb.ConnCase
  use I18NAPI.Fixtures, [:setup_with_auth, :user, :project]

  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.{Invitation, User}
  alias I18NAPI.Repo

  @invite_user_data %{
    name: "invited user",
    email: "invited@email.test",
    role: :translator,
    message: "some message"
  }

  describe "invite" do
    test "if invite data is valid", %{conn: conn} do
      project = fixture(:project, user: conn.user)

      conn =
        post(conn, project_invitation_path(conn, :invite, project.id), invite: @invite_user_data)

      assert %{"id" => id} = json_response(conn, 201)["data"]
      assert %User{} = user = Accounts.get_user!(id)
      assert user.is_confirmed == false
      assert is_nil(user.confirmation_token) == false
      assert is_nil(user.restore_token) == false
    end

    test "if invite data is empty", %{conn: conn} do
      project = fixture(:project, user: conn.user)

      conn = post(conn, project_invitation_path(conn, :invite, project.id), invite: %{})
      assert %{"errors" => %{"detail" => "Bad Request"}} = json_response(conn, 400)
    end

    test "if required field is not exists", %{conn: conn} do
      project = fixture(:project, user: conn.user)

      conn =
        post(conn, project_invitation_path(conn, :invite, project.id),
          invite: %{email: "invited@email.test", role: :translator, message: "some message"}
        )

      assert %{"errors" => %{"name" => ["can't be blank"]}} = json_response(conn, 422)
    end

    test "if inviter not are owner", %{conn: conn} do
      more_alter_user = fixture(:user_more_alter)
      project = fixture(:project, user: more_alter_user)

      conn =
        post(conn, project_invitation_path(conn, :invite, project.id), invite: @invite_user_data)

      assert %{"errors" => %{"detail" => "Forbidden"}} = json_response(conn, 403)
    end

    test "if inviter role too low", %{conn: conn} do
      more_alter_user = fixture(:user_more_alter)
      project = fixture(:project, user: more_alter_user)

      I18NAPI.Projects.create_user_roles(%{
        role: :translator,
        project_id: project.id,
        user_id: conn.user.id
      })

      conn =
        post(conn, project_invitation_path(conn, :invite, project.id), invite: @invite_user_data)

      assert %{"errors" => %{"detail" => "Forbidden"}} = json_response(conn, 403)
    end
  end

  describe "accept" do
    test "if invite data is valid", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      user = fixture(:user_alter)
      prepared_data = @invite_user_data |> Map.put(:project_id, project.id)
      {:ok, prepared_user} = Invitation.prepare_user(prepared_data, conn.user)

      {:ok, %User{} = user} =
        Invitation.send_invite_email(prepared_user, conn.user, project, :translator, "message")

      conn =
        post(conn, invitation_path(conn, :accept),
          user:
            %{}
            |> Map.put(:restore_token, user.restore_token)
            |> Map.put(:password, "Qwerty1234!")
            |> Map.put(:password_confirmation, "Qwerty1234!")
        )

      assert %{"ok" => %{"detail" => "User accepted"}} = json_response(conn, 200)
    end

    test "if token is invalid", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      user = fixture(:user_alter)
      prepared_data = @invite_user_data |> Map.put(:project_id, project.id)
      {:ok, prepared_user} = Invitation.prepare_user(prepared_data, conn.user)

      {:ok, %User{} = user} =
        Invitation.send_invite_email(prepared_user, conn.user, project, :translator, "message")

      conn =
        post(conn, invitation_path(conn, :accept),
          user:
            %{}
            |> Map.put(:restore_token, "bad token")
            |> Map.put(:password, "Qwerty1234!")
            |> Map.put(:password_confirmation, "Qwerty1234!")
        )

      assert %{"errors" => %{"detail" => "Unauthorized"}} = json_response(conn, 401)
    end

    test "if password is invalid", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      user = fixture(:user_alter)
      prepared_data = @invite_user_data |> Map.put(:project_id, project.id)
      {:ok, prepared_user} = Invitation.prepare_user(prepared_data, conn.user)

      {:ok, %User{} = user} =
        Invitation.send_invite_email(prepared_user, conn.user, project, :translator, "message")

      conn =
        post(conn, invitation_path(conn, :accept),
          user:
            %{}
            |> Map.put(:restore_token, user.restore_token)
            |> Map.put(:password, "bad")
            |> Map.put(:password_confirmation, "bad")
        )

      assert %{
               "error" => %{
                 "detail" => "Password must have 8-50 symbols"
               }
             } = json_response(conn, 422)
    end

    test "if password is unconfirmed", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      user = fixture(:user_alter)
      prepared_data = @invite_user_data |> Map.put(:project_id, project.id)
      {:ok, prepared_user} = Invitation.prepare_user(prepared_data, conn.user)

      {:ok, %User{} = user} =
        Invitation.send_invite_email(prepared_user, conn.user, project, :translator, "message")

      conn =
        post(conn, invitation_path(conn, :accept),
          user:
            %{}
            |> Map.put(:restore_token, user.restore_token)
            |> Map.put(:password, "Qwerty1234!")
            |> Map.put(:password_confirmation, "bad")
        )

      assert %{"error" => %{"detail" => "Does not match confirmation"}} = json_response(conn, 422)
    end
  end

  describe "reject invite" do
    test "if reject data is valid", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      user = fixture(:user_alter)
      prepared_data = @invite_user_data |> Map.put(:project_id, project.id)
      {:ok, prepared_user} = Invitation.prepare_user(prepared_data, conn.user)

      {:ok, %User{} = user} =
        Invitation.send_invite_email(prepared_user, conn.user, project, :translator, "message")

      no_content_response =
        delete(conn, project_invitation_path(conn, :reject, project.id), user_id: user.id)

      assert response(no_content_response, 204)
      no_content_response = delete(conn, user_path(conn, :show, conn.user))
      assert response(no_content_response, 204)
    end

    test "if project_id is another", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      user = fixture(:user_alter)
      prepared_data = @invite_user_data |> Map.put(:project_id, project.id)
      {:ok, prepared_user} = Invitation.prepare_user(prepared_data, conn.user)

      {:ok, %User{} = user} =
        Invitation.send_invite_email(prepared_user, conn.user, project, :translator, "message")

      response = delete(conn, project_invitation_path(conn, :reject, 1), user_id: user.id)

      assert %{"errors" => %{"detail" => "Forbidden"}} = json_response(response, 403)
    end

    test "if user_id is another", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      user = fixture(:user_alter)
      prepared_data = @invite_user_data |> Map.put(:project_id, project.id)
      {:ok, prepared_user} = Invitation.prepare_user(prepared_data, conn.user)

      {:ok, %User{} = user} =
        Invitation.send_invite_email(prepared_user, conn.user, project, :translator, "message")

      response = delete(conn, project_invitation_path(conn, :reject, project.id), user_id: 1)

      assert %{"errors" => %{"detail" => "Forbidden"}} = json_response(response, 403)
    end

    test "if data is invalid", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      user = fixture(:user_alter)
      prepared_data = @invite_user_data |> Map.put(:project_id, project.id)
      {:ok, prepared_user} = Invitation.prepare_user(prepared_data, conn.user)

      {:ok, %User{} = user} =
        Invitation.send_invite_email(prepared_user, conn.user, project, :translator, "message")

      response = delete(conn, project_invitation_path(conn, :reject, project.id), user_id: nil)

      assert %{"errors" => %{"detail" => "Bad Request"}} = json_response(response, 400)
    end
  end
end
