defmodule IncrementalSlug.TestRepo do
  use Ecto.Repo,
  otp_app: :incremental_slug,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox

  def init(_type, config) do
    {:ok, Keyword.put(config, :url, System.get_env("DATABASE_URL"))}
  end
end
