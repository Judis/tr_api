defmodule I18NAPI.UserEmail do
  use Phoenix.Swoosh, view: I18NAPIWeb.EmailView, layout: {I18NAPIWeb.LayoutView, :email}

  alias I18NAPI.Accounts.Confirmation

  def create_confirmation_email(user) do
    new()
    |> to({user.name, user.email})
    |> from({Application.fetch_env!(:api, :sender), Application.fetch_env!(:api, :sender_email)})
    |> subject("i18n confirmation email")
    |> render_body("confirmation_email.html", %{
      username: user.name,
      confirmation_token: user.confirmation_token,
      confirmation_link: Confirmation.create_confirmation_link(user.confirmation_token)
    })
  end
end
