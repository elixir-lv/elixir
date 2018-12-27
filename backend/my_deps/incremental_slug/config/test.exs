use Mix.Config

config :logger, level: :warn

config :incremental_slug, ecto_repos: [IncrementalSlug.TestRepo]

config :incremental_slug, IncrementalSlug.TestRepo,
  username: "postgres",
  password: "postgres",
  database: "incremental_slug_test",
  hostname: "172.60.1.15",
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "test/repo/"
