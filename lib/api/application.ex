defmodule I18NAPI.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # Deprecated in Elixir 1.5
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(I18NAPI.Repo, []),
      # Start the endpoint when the application starts
      supervisor(I18NAPIWeb.Endpoint, []),
      # Start the Statistics worker
      supervisor(I18NAPI.Translations.StatisticsSupervisor, [])
      # Start your own worker by calling: I18NAPI.Worker.start_link(arg1, arg2, arg3)
      # worker(I18NAPI.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: I18NAPI.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    I18NAPIWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
