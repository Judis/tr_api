defmodule I18NAPIWeb.UploadLocaleControllerTest do
  use ExUnit.Case, async: true
  @moduletag :upload_locale_controller

  use I18NAPIWeb.ConnCase
  use I18NAPI.Fixtures, [:setup_with_auth, :user, :project, :locale]

  describe "create locale" do
    setup [:project]

    test "renders locale when data is valid", %{conn: conn, project: project} do
      locale = fixture(:locale, %{project_id: project.id})

      upload = %Plug.Upload{
        path: "test/support/upload_controller_fixture.json",
        filename: "upload_controller_fixture.json"
      }

      conn =
        post(conn, project_locale_upload_locale_path(conn, :upload, project.id, locale.id), %{
          "" => upload
        })

      assert json_response(conn, 200)
    end
  end

  defp project(%{conn: conn}), do: {:ok, project: fixture(:project, user: conn.user)}
end
