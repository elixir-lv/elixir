defmodule IncrementalSlug.TestRepo2 do
  use Ecto.Repo,
    otp_app: :incremental_slug,
    adapter: Ecto.Adapters.MySQL,
    pool: Ecto.Adapters.SQL.Sandbox

  def init(_type, config) do
    {:ok, Keyword.put(config, :url, System.get_env("DATABASE_URL"))}
  end
end
