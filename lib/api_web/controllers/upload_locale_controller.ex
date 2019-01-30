defmodule I18NAPIWeb.UploadLocaleController do
  use I18NAPIWeb, :controller

  alias I18NAPI.Parsers
  alias I18NAPI.Translations.Import

  action_fallback(I18NAPIWeb.FallbackController)

  def upload(conn, %{"" => %Plug.Upload{} = file_params}) do
    {:ok, content} = File.read(file_params.path)
    [_, ext] = Regex.run(~r/\.(\w*)\z/, file_params.filename)
    Import.import_locale(conn.params["locale_id"], Parsers.parse(content, ext))
    render(conn, "200.json")
  end
end
