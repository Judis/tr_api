defmodule I18NAPIWeb.EchoController do
  use I18NAPIWeb, :controller

  action_fallback(I18NAPIWeb.FallbackController)

  def index(conn, _params) do
    render(conn, "index.json")
  end
end
