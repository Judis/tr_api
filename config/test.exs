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
  database: "i18n_api_test",
  username: System.get_env("DB_USERNAME") || "postgres",
  password: System.get_env("DB_PASSWORD") || "",
  hostname: System.get_env("DB_HOSTNAME") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :api, I18NAPI.Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "api",
  ttl: { 30, :days },
  verify_issuer: true,
  secret_key: "test",
  serializer: I18NAPI.Guardian

config :bcrypt_elixir, :log_rounds, 4

config :api, I18NAPI.Mailer,
       adapter: Swoosh.Adapters.Test

config :api,
       sender: "Dr B Banner",
       sender_email: "hulk.smash@example.com"

config :api, :statistics_watcher,
       statistic_recalculating_period: 1
