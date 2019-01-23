defmodule I18NAPIWeb.InvitationControllerTest do
  use ExUnit.Case, async: true
  @moduletag :invitation_controller

  use I18NAPIWeb.ConnCase
  use I18NAPI.Fixtures, [:setup_with_auth, :user, :project, :invitation]

  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User
  alias I18NAPI.Projects.Invitation

  describe "invite" do
    test "if invite data is valid", %{conn: conn} do
      project = fixture(:project, user: conn.user)

      conn =
        post(conn, project_invitation_path(conn, :invite, project.id), invite: attrs(:invite))

      assert %{"recipient_id" => recipient_id} = json_response(conn, 201)["data"]
      assert %User{} = user = Accounts.get_user!(recipient_id)
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

      conn = post(conn, project_invitation_path(conn, :invite, project.id), invite: %{})
      errors = Map.get(json_response(conn, 400), "errors")
      assert Map.get(errors, "detail") == "Bad Request"

      assert Map.get(errors, "validation") == [
               %{"role" => "can't be blank"},
               %{"message" => "can't be blank"}
             ]
    end

    test "if inviter not are owner", %{conn: conn} do
      more_alter_user = fixture(:user_more_alter)
      project = fixture(:project, user: more_alter_user)

      conn =
        post(conn, project_invitation_path(conn, :invite, project.id), invite: attrs(:invite))

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
        post(conn, project_invitation_path(conn, :invite, project.id), invite: attrs(:invite))

      assert %{"errors" => %{"detail" => "Forbidden"}} = json_response(conn, 403)
    end
  end

  describe "accept_user" do
    test "if invite data is valid", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      prepared_data = attrs(:invite) |> Map.put(:project_id, project.id)
      {:ok, recipient} = Invitation.prepare_user(prepared_data)

      invite =
        fixture(:invite,
          invite:
            prepared_data
            |> Map.put(:recipient_id, recipient.id)
            |> Map.put(:inviter_id, conn.user.id)
        )

      conn =
        post(conn, invitation_path(conn, :accept_user),
          user: %{
            token: invite.token,
            password: "Qwerty1234!",
            password_confirmation: "Qwerty1234!"
          }
        )

      assert %{"ok" => %{"detail" => "User accepted"}} = json_response(conn, 200)
    end

    test "if token is invalid", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      prepared_data = attrs(:invite) |> Map.put(:project_id, project.id)
      {:ok, recipient} = Invitation.prepare_user(prepared_data)

      fixture(:invite,
        invite:
          prepared_data
          |> Map.put(:recipient_id, recipient.id)
          |> Map.put(:inviter_id, conn.user.id)
      )

      conn =
        post(conn, invitation_path(conn, :accept_user),
          user: %{
            token: "bad token",
            password: "Qwerty1234!",
            password_confirmation: "Qwerty1234!"
          }
        )

      assert %{"errors" => %{"detail" => "Unauthorized"}} = json_response(conn, 401)
    end

    test "if token is nil", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      prepared_data = attrs(:invite) |> Map.put(:project_id, project.id)
      {:ok, recipient} = Invitation.prepare_user(prepared_data)

      fixture(:invite,
        invite:
          prepared_data
          |> Map.put(:recipient_id, recipient.id)
          |> Map.put(:inviter_id, conn.user.id)
      )

      conn =
        post(conn, invitation_path(conn, :accept_user),
          user: %{
            token: nil,
            password: "Qwerty1234!",
            password_confirmation: "Qwerty1234!"
          }
        )

      assert %{"errors" => %{"detail" => "Bad Request"}} = json_response(conn, 400)
    end

    test "if password is invalid", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      prepared_data = attrs(:invite) |> Map.put(:project_id, project.id)
      {:ok, recipient} = Invitation.prepare_user(prepared_data)

      invite =
        fixture(:invite,
          invite:
            prepared_data
            |> Map.put(:recipient_id, recipient.id)
            |> Map.put(:inviter_id, conn.user.id)
        )

      conn =
        post(conn, invitation_path(conn, :accept_user),
          user: %{
            token: invite.token,
            password: "bad",
            password_confirmation: "bad"
          }
        )

      assert %{
               "errors" => %{
                 "password" => ["should be at least 8 character(s)"]
               }
             } = json_response(conn, 422)
    end

    test "if password is nil", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      prepared_data = attrs(:invite) |> Map.put(:project_id, project.id)
      {:ok, recipient} = Invitation.prepare_user(prepared_data)

      invite =
        fixture(:invite,
          invite:
            prepared_data
            |> Map.put(:recipient_id, recipient.id)
            |> Map.put(:inviter_id, conn.user.id)
        )

      conn =
        post(conn, invitation_path(conn, :accept_user),
          user: %{
            token: invite.token,
            password: nil,
            password_confirmation: "Qwerty1234!"
          }
        )

      assert %{"errors" => %{"detail" => "Bad Request"}} = json_response(conn, 400)
    end

    test "if password is unconfirmed", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      prepared_data = attrs(:invite) |> Map.put(:project_id, project.id)
      {:ok, recipient} = Invitation.prepare_user(prepared_data)

      invite =
        fixture(:invite,
          invite:
            prepared_data
            |> Map.put(:recipient_id, recipient.id)
            |> Map.put(:inviter_id, conn.user.id)
        )

      conn =
        post(conn, invitation_path(conn, :accept_user),
          user: %{
            token: invite.token,
            password: "Qwerty1234!",
            password_confirmation: "bad!"
          }
        )

      assert %{"errors" => %{"password_confirmation" => ["does not match confirmation"]}} =
               json_response(conn, 422)
    end
  end

  describe "accept_project" do
    test "if invite data is valid", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      prepared_data = attrs(:invite) |> Map.put(:project_id, project.id)
      recipient = fixture(:user_alter)

      invite =
        fixture(:invite,
          invite:
            prepared_data
            |> Map.put(:recipient_id, recipient.id)
            |> Map.put(:inviter_id, conn.user.id)
        )

      conn =
        post(conn, project_invitation_path(conn, :accept_project, project.id), token: invite.token)

      assert %{"ok" => %{"detail" => "User accepted"}} = json_response(conn, 200)
    end

    test "if token is invalid", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      prepared_data = attrs(:invite) |> Map.put(:project_id, project.id)
      recipient = fixture(:user_alter)

      fixture(:invite,
        invite:
          prepared_data
          |> Map.put(:recipient_id, recipient.id)
          |> Map.put(:inviter_id, conn.user.id)
      )

      conn =
        post(conn, project_invitation_path(conn, :accept_project, project.id),
          user: %{token: "bad token"}
        )

      assert %{"errors" => %{"detail" => "Bad Request"}} = json_response(conn, 400)
    end

    test "if token is nil", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      prepared_data = attrs(:invite) |> Map.put(:project_id, project.id)
      recipient = fixture(:user_alter)

      fixture(:invite,
        invite:
          prepared_data
          |> Map.put(:recipient_id, recipient.id)
          |> Map.put(:inviter_id, conn.user.id)
      )

      conn =
        post(conn, project_invitation_path(conn, :accept_project, project.id), user: %{token: nil})

      assert %{"errors" => %{"detail" => "Bad Request"}} = json_response(conn, 400)
    end
  end

  describe "reject invite" do
    test "if reject data is valid", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      prepared_data = attrs(:invite) |> Map.put(:project_id, project.id)
      recipient = fixture(:user_alter)

      invite =
        fixture(:invite,
          invite:
            prepared_data
            |> Map.put(:recipient_id, recipient.id)
            |> Map.put(:inviter_id, conn.user.id)
        )

      no_content_response =
        delete(conn, project_invitation_path(conn, :reject, project.id), invite_id: invite.id)

      assert response(no_content_response, 204)
      no_content_response = delete(conn, user_path(conn, :show, conn.user))
      assert response(no_content_response, 204)
    end

    test "if user_id is another", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      prepared_data = attrs(:invite) |> Map.put(:project_id, project.id)
      recipient = fixture(:user_alter)

      fixture(:invite,
        invite:
          prepared_data
          |> Map.put(:recipient_id, recipient.id)
          |> Map.put(:inviter_id, conn.user.id)
      )

      response = delete(conn, project_invitation_path(conn, :reject, project.id), invite_id: 1)

      assert %{"errors" => %{"detail" => "Forbidden"}} = json_response(response, 403)
    end

    test "if data is invalid", %{conn: conn} do
      project = fixture(:project, user: conn.user)
      prepared_data = attrs(:invite) |> Map.put(:project_id, project.id)
      recipient = fixture(:user_alter)

      fixture(:invite,
        invite:
          prepared_data
          |> Map.put(:recipient_id, recipient.id)
          |> Map.put(:inviter_id, conn.user.id)
      )

      response = delete(conn, project_invitation_path(conn, :reject, project.id), invite_id: nil)

      assert %{"errors" => %{"detail" => "Bad Request"}} = json_response(response, 400)
    end
  end
end
