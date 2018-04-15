defmodule I18NAPIWeb.UserLocalesController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Projects
  alias I18NAPI.Projects.UserLocales

  action_fallback(I18NAPIWeb.FallbackController)

  def index(conn, _params) do
    user_locales = Projects.list_user_locales()
    render(conn, "index.json", user_locales: user_locales)
  end

  def create(conn, %{"user_locales" => user_locales_params}) do
    with {:ok, %UserLocales{} = user_locales} <- Projects.create_user_locales(user_locales_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_locales_path(conn, :show, user_locales))
      |> render("show.json", user_locales: user_locales)
    end
  end

  def show(conn, %{"id" => id}) do
    user_locales = Projects.get_user_locales!(id)
    render(conn, "show.json", user_locales: user_locales)
  end

  def update(conn, %{"id" => id, "user_locales" => user_locales_params}) do
    user_locales = Projects.get_user_locales!(id)

    with {:ok, %UserLocales{} = user_locales} <-
           Projects.update_user_locales(user_locales, user_locales_params) do
      render(conn, "show.json", user_locales: user_locales)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_locales = Projects.get_user_locales!(id)

    with {:ok, %UserLocales{}} <- Projects.delete_user_locales(user_locales) do
      send_resp(conn, :no_content, "")
    end
  end
end
