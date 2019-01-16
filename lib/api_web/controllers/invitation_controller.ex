defmodule I18NAPIWeb.InvitationController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.{Invitation, User}
  alias I18NAPI.Projects
  alias I18NAPI.Projects.UserRoles

  action_fallback(I18NAPIWeb.FallbackController)

  def invite(conn, %{
        "user_id" => id,
        "invite" =>
          %{
            "name" => name,
            "email" => email,
            "project_id" => project_id,
            "role" => role,
            "message" => message
          } = invite_params
      })
      when is_nil(id) or is_nil(name) or is_nil(email) or is_nil(project_id) or is_nil(role) or
             is_nil(message),
      do: {:error, :bad_request}

  def invite(conn, %{
        "user_id" => _,
        "invite" =>
          %{"name" => _, "email" => _, "project_id" => _, "role" => _, "message" => _} =
            invite_params
      }) do
    invite_params = I18NAPI.Utilities.key_to_atom(invite_params)

    with :ok <- check_access_policy(invite_params, conn),
         {:ok, %User{} = user} <- Invitation.create_invite(invite_params, conn.user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_invitation_path(conn, :invite, user))
      |> render("show.json", user: user)
    end
  end

  def invite(_conn, _args) do
    {:error, :bad_request}
  end

  defp check_access_policy(invite_params, conn) do
    with %UserRoles{} <-
           user_role = Projects.get_user_roles!(invite_params.project_id, conn.user.id) do
      case user_role.role do
        :admin -> :ok
        :manager -> :ok
        _ -> {:error, :forbidden}
      end
    else
      _ -> {:error, :forbidden}
    end
  end

  def reject(conn, %{
        "user_id" => id,
        "reject" => %{"user_id" => user_id, "project_id" => project_id} = reject_params
      })
      when is_nil(id) or is_nil(user_id) or is_nil(project_id),
      do: {:error, :bad_request}

  def reject(conn, %{
        "user_id" => _,
        "reject" => %{"user_id" => _, "project_id" => _} = reject_params
      }) do
    reject_params = I18NAPI.Utilities.key_to_atom(reject_params)

    with :ok <- check_access_policy(reject_params, conn),
         %User{} = user <- Accounts.get_user(reject_params.user_id),
         false <- is_nil(user.invited_at),
         {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    else
      _ -> {:error, :forbidden}
    end
  end

  def accept(conn, %{
        "user" =>
          %{
            "restore_token" => restore_token,
            "password" => password,
            "password_confirmation" => password_confirmation
          } = user_params
      })
      when is_nil(restore_token) or is_nil(password) or is_nil(password_confirmation),
      do: {:error, :bad_request}

  def accept(conn, %{
        "user" =>
          %{
            "restore_token" => restore_token,
            "password" => password,
            "password_confirmation" => password_confirmation
          } = user_params
      }) do
    user_params = I18NAPI.Utilities.key_to_string(user_params)

    result = Invitation.accept_user_by_token(restore_token, password, password_confirmation)

    case result do
      {:ok, _} ->
        conn |> put_status(200) |> render("200.json")

      {:error, :unauthorized} ->
        {:error, :unauthorized}

      {:error, :forbidden} ->
        {:error, :forbidden}

      {:error, :nil_found} ->
        {:error, :bad_request}

      {:error, error} ->
        conn
        |> put_status(422)
        |> render("422.json", %{detail: error.errors |> Enum.at(0) |> elem(0)})
    end
  end

  def accept(_conn, _args) do
    {:error, :bad_request}
  end
end
