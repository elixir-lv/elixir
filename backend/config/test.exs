use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :backend, BackendWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :backend, Backend.Repo,
  username: "root",
  password: "",
  database: "backend_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

if File.exists?("config/test.secret.exs") do
  import_config "test.secret.exs"
end
