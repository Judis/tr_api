# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :api,
  namespace: I18NAPI,
  ecto_repos: [I18NAPI.Repo]

# Configures the endpoint
config :api, I18NAPIWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "BE6pRSCgEabhsEHvwmmH/rFFxnymvCs4uCIJbvRTcjSwopVjv5wOccaUQnRZlv+N",
  render_errors: [view: I18NAPIWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: I18NAPI.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :api, :statistics_watcher,
       statistic_recalculating_period: 1000

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
