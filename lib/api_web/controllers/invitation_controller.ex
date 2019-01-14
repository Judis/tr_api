defmodule I18NAPIWeb.InvitationController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Accounts.{Invitation, User}

  action_fallback(I18NAPIWeb.FallbackController)

  def invite(conn, %{
        "user_id" => _,
        "invite" =>
          %{
            "name" => _,
            "email" => _,
            "project_id" => _,
            "role" => _,
            "message" => _
          } = invite_params
      }) do
    invite_params = I18NAPI.Utilities.key_to_atom(invite_params)

    with {:ok, %User{} = user} <- Invitation.start_invite_creating(invite_params, conn.user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_invitation_path(conn, :invite, user))
      |> render("show.json", user: user)
    end
  end

  def invite(_conn, _args) do
    {:error, :bad_request}
  end

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
        conn |> put_status(200) |> render("200.json")

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
