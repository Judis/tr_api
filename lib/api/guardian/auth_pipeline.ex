defmodule I18NAPI.Guardian.AuthPipeline.JSON do
  @moduledoc false

  use Guardian.Plug.Pipeline,
    otp_app: :api,
    module: I18NAPI.Guardian,
    error_handler: I18NAPI.Guardian.AuthErrorHandler

  plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end

defmodule I18NAPI.Guardian.AuthPipeline.Authenticate do
  @moduledoc false

  use Guardian.Plug.Pipeline,
    otp_app: :api,
    module: I18NAPI.Guardian,
    error_handler: I18NAPI.Guardian.AuthErrorHandler

  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource, ensure: true)
end
