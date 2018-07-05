defmodule Mix.Tasks.Db.SlowQuery do
  import Mix.Ecto

  @shortdoc "Simulate a slow query to test DB timeouts."

  @moduledoc """
  * mix db.slow_query
  """
  use Mix.Task

  def run(args) do
    ensure_started(ElixirBackend.Repo, [])
    query = "SELECT sleep(60)"
    IO.inspect  Ecto.Adapters.SQL.query!(ElixirBackend.Repo, query, [])

    # [error] Mariaex.Protocol (#PID<0.216.0>) disconnected: ** (DBConnection.ConnectionError) client #PID<0.74.0> timed out because it checked out the connection for longer than 30000ms
  end
end
