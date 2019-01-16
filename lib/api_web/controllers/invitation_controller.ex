defmodule I18NAPIWeb.InvitationController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.{Invitation, User}
  alias I18NAPI.Projects
  alias I18NAPI.Projects.UserRoles
  alias I18NAPI.Utilities

  action_fallback(I18NAPIWeb.FallbackController)

  def invite(conn, %{
        "project_id" => project_id,
        "invite" => %{"role" => _, "message" => _} = invite_params
      }) do
    with :ok <- check_access_policy(project_id, conn.user.id),
         {:ok, %User{} = user} <-
           invite_params
           |> Map.put(:project_id, project_id)
           |> Utilities.key_to_atom()
           |> Invitation.create_invite(conn.user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", project_invitation_path(conn, :invite, project_id))
      |> render("show.json", user: user)
    end
  end

  def invite(_conn, _args) do
    {:error, :bad_request}
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

  def reject(conn, %{"project_id" => project_id, "user_id" => user_id}) do
    if is_nil(user_id) do
      {:error, :bad_request}
    else
      with :ok <- check_access_policy(project_id, conn.user.id),
           %User{} = user <- Accounts.get_user(user_id),
           false <- is_nil(user.invited_at),
           {:ok, %User{}} <- Accounts.delete_user(user) do
        send_resp(conn, :no_content, "")
      else
        _ -> {:error, :forbidden}
      end
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
