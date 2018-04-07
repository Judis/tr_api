defmodule I18NAPIWeb.Router do
  use I18NAPIWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", I18NAPIWeb do
    pipe_through :api
  end
end
