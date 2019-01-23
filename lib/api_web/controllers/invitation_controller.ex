defmodule I18NAPIWeb.InvitationController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Accounts.User
  alias I18NAPI.Projects
  alias I18NAPI.Projects.{Invitation, Invite, UserRoles}
  alias I18NAPI.Utilities

  action_fallback(I18NAPIWeb.FallbackController)

  def invite(conn, %{"project_id" => project_id, "invite" => invite_params}) do
    with :ok <- check_access_policy(project_id, conn.user.id),
         {:ok, invite_params} <- Invitation.check_invite_params(invite_params),
         {:ok, %Invite{} = invite} <-
           invite_params
           |> Map.put(:project_id, project_id)
           |> Map.put(:inviter_id, conn.user.id)
           |> Utilities.key_to_atom()
           |> Invitation.start_invitation(conn.user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", project_invitation_path(conn, :invite, project_id))
      |> render("show.json", invite: invite)
    end
  end

  defp check_access_policy(project_id, user_id) do
    with %UserRoles{} <- user_role = Projects.get_user_roles!(project_id, user_id) do
      case user_role.role do
        :admin -> :ok
        :manager -> :ok
        _ -> {:error, :forbidden}
      end
    else
      _ -> {:error, :forbidden}
    end
  end

  def accept_user(conn, %{
        "user" => %{
          "token" => token,
          "password" => password,
          "password_confirmation" => password_confirmation
        }
      })
      when is_nil(token) or is_nil(password) or is_nil(password_confirmation),
      do: {:error, :bad_request}

  def accept_user(conn, %{
        "user" => %{
          "token" => token,
          "password" => password,
          "password_confirmation" => password_confirmation
        }
      }) do
    with {:ok, %User{}} <- Invitation.accept_user_by_token(token, password, password_confirmation) do
      conn |> put_status(200) |> render("200.json")
    end
  end

  def accept_user(_conn, _args), do: {:error, :bad_request}

  def accept_project(conn, %{"token" => token}) when is_nil(token), do: {:error, :bad_request}

  def accept_project(conn, %{"token" => token}) do
    with {:ok, %Invite{}} <- Invitation.accept_project_by_token(token) do
      conn |> put_status(200) |> render("200.json")
    end
  end

  def accept_project(_conn, _args), do: {:error, :bad_request}

  def reject(conn, %{"invite_id" => nil}), do: {:error, :bad_request}

  def reject(conn, %{"invite_id" => invite_id}) do
    with {:ok, invite} <- check_invite_access_policy(invite_id, conn.user.id),
         Projects.safely_delete_invite(invite) do
      send_resp(conn, :no_content, "")
    else
      _ -> {:error, :forbidden}
    end
  end

  defp check_invite_access_policy(invite_id, user_id) do
    with %Invite{} <- invite = Projects.get_invite(invite_id),
         user_id == invite.inviter_id do
      {:ok, invite}
    else
      _ -> {:error, :forbidden}
    end
  end
end
