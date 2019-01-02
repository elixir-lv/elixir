use Mix.Config

config :logger, level: :warn

config :incremental_slug, ecto_repos: [IncrementalSlug.TestRepo]
config :incremental_slug, repo: IncrementalSlug.TestRepo

config :incremental_slug, IncrementalSlug.TestRepo,
  username: "mysql",
  password: "mysql",
  database: "incremental_slug_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "test/support/mysql"

if File.exists?("config/mysql.secret.exs") do
  import_config "mysql.secret.exs"
end
