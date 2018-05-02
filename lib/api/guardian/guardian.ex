defmodule I18NAPI.Guardian do
  @moduledoc """
  Guardian logic implementation to implement JWT token support.
  """

  use Guardian, otp_app: :api
  alias I18NAPI.Accounts
  alias I18NAPI.Accounts.User

  def subject_for_token(%User{} = resource, _claims) do
    sub = to_string(resource.id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :invalid_user}
  end

  def resource_from_claims(%{} = claims) do
    id = claims["sub"]
    resource = Accounts.get_user!(id)
    {:ok, resource}
  end

  def resource_from_claims(_claims) do
    {:error, :invalid_claims}
  end
end
