defmodule I18NAPIWeb.InvitationControllerTest do
  use ExUnit.Case, async: true
  @moduletag :invitation_controller

  use I18NAPIWeb.ConnCase
  use I18NAPI.Fixtures, [:setup_with_auth, :user, :project]

  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User
  alias I18NAPI.Repo

  describe "invite" do
    test "if invite data is valid", %{conn: conn} do
      project = fixture(:project, user: conn.user)

      conn =
        post(conn, user_invitation_path(conn, :invite, conn.user),
          invite: @invite_user_data |> Map.put(:project_id, project.id)
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]
      assert %User{} = user = Accounts.get_user!(id)
      assert user.is_confirmed == false
      assert is_nil(user.confirmation_token) == false
      assert is_nil(user.restore_token) == false
    end
  end

  describe "accept" do
    test "if invite data is valid", %{conn: conn} do
      project = fixture(:project, user: conn.user)

      conn =
        post(conn, user_invitation_path(conn, :invite, conn.user),
          invite: @invite_user_data |> Map.put(:project_id, project.id)
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]
      assert %User{} = user = Accounts.get_user!(id)
      assert user.is_confirmed == false
      assert is_nil(user.confirmation_token) == false
      assert is_nil(user.restore_token) == false
    end
  end
end
