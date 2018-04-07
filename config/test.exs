use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :api, I18NAPIWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :api, I18NAPI.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "Judis",
  password: "",
  database: "i18n_api_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
