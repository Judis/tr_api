defmodule I18NAPIWeb.UserView do
  use I18NAPIWeb, :view
  alias I18NAPIWeb.UserView

  def render("sign_in.json", %{user: user, jwt: jwt}) do
    %{
      status: :ok,
      data: %{
        token: jwt,
        email: user.email
      },
      message:
        "You are successfully logged in! Add this token to authorization header to make authorized requests."
    }
  end

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      password_hash: user.password_hash,
      is_confirmed: user.is_confirmed,
      source: user.source,
      confirmation_token: user.confirmation_token,
      restore_token: user.restore_token,
      failed_sign_in_attempts: user.failed_sign_in_attempts,
      failed_restore_attempts: user.failed_restore_attempts,
      confirmed_at: user.confirmed_at,
      confirmation_sent_at: user.confirmation_sent_at,
      restore_requested_at: user.restore_requested_at,
      restore_accepted_at: user.restore_accepted_at,
      last_visited_at: user.last_visited_at,
      invited_at: user.invited_at
    }
  end
end
