use Mix.Config

config :logger, level: :warn

config :incremental_slug, ecto_repos: [IncrementalSlug.TestRepo]
config :incremental_slug, repo: IncrementalSlug.TestRepo

config :incremental_slug, IncrementalSlug.TestRepo,
  username: "postgres",
  password: "postgres",
  database: "incremental_slug_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "test/support/"

if File.exists?("config/test.secret.exs") do
  import_config "test.secret.exs"
end
