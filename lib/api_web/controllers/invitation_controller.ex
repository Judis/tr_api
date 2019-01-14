defmodule I18NAPIWeb.InvitationController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Accounts.{Invitation, User}
  alias I18NAPI.Projects
  alias I18NAPI.Projects.UserRoles

  action_fallback(I18NAPIWeb.FallbackController)

  def invite(conn, %{
        "user_id" => _,
        "invite" =>
          %{"name" => _, "email" => _, "project_id" => _, "role" => _, "message" => _} =
            invite_params
      }) do
    invite_params = I18NAPI.Utilities.key_to_atom(invite_params)

    Projects.get_user_roles!(invite_params.project_id, conn.user.id)
    |> check_user_roles()
    |> start_invite_creating(invite_params, conn)
  end

  def invite(_conn, _args) do
    {:error, :bad_request}
  end

  defp check_user_roles(%UserRoles{} = user_role) do
    user_role.role
  end

  defp check_user_roles(_) do
    {:error, :forbidden}
  end

  defp start_invite_creating(role, invite_params, conn) when :admin == role or :manager == role do
    with {:ok, %User{} = user} <- Invitation.create_invite(invite_params, conn.user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_invitation_path(conn, :invite, user))
      |> render("show.json", user: user)
    end
  end

  defp start_invite_creating(_, _, _), do: {:error, :forbidden}

  def accept(conn, %{"user" => user_params}) do
    user_params = I18NAPI.Utilities.key_to_string(user_params)

    result =
      Invitation.accept_user_by_token(
        user_params |> Map.get("restore_token"),
        user_params |> Map.get("password"),
        user_params |> Map.get("password_confirmation")
      )

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
