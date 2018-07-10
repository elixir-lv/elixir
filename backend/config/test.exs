use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :elixir_backend, ElixirBackendWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :elixir_backend, ElixirBackend.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "",
  database: "elixir_backend_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
