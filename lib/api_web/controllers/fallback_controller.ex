defmodule I18NAPIWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use I18NAPIWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(I18NAPIWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, :no_content}) do
    conn
    |> put_status(:no_content)
    |> render(I18NAPIWeb.ErrorView, :"204")
  end

  def call(conn, {:error, :bad_request, validation}) do
    conn
    |> put_status(:bad_request)
    |> render(I18NAPIWeb.ErrorView, :"400", validation: validation)
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> render(I18NAPIWeb.ErrorView, :"400")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> render(I18NAPIWeb.ErrorView, :"401")
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> render(I18NAPIWeb.ErrorView, :"403")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(I18NAPIWeb.ErrorView, :"404")
  end

  def call(conn, {:error, error}) do
    conn
    |> put_status(:not_found)
    |> render(I18NAPIWeb.ErrorView, :"422", detail: error.errors |> Enum.at(0) |> elem(0))
  end
end
