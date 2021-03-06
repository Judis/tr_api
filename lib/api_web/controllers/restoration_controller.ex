defmodule I18NAPIWeb.RestorationController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Accounts.Restoration

  action_fallback(I18NAPIWeb.FallbackController)

  def request(conn, %{"email" => email}) do
    Restoration.start_password_restoration(email)
    render(conn, "200.json")
  end

  def request(_conn, _args), do: {:error, :bad_request}

  def reset(conn, %{"user" => user_params}) do
    user_params
    |> I18NAPI.Utilities.key_to_atom()
    |> Restoration.restore_user_by_token()
    |> case do
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

  def reset(_conn, _args), do: {:error, :bad_request}
end
