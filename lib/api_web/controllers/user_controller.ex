defmodule I18NAPIWeb.UserController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User

  action_fallback(I18NAPIWeb.FallbackController)

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      {:ok, jwt, _full_claims} = I18NAPI.Guardian.encode_and_sign(user)

      conn
      |> render("sign_in.json", user: user, jwt: jwt)

      # conn
      # |> put_status(:created)
      # |> put_resp_header("location", user_path(conn, :show, user))
      # |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
