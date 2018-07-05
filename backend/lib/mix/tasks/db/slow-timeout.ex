defmodule Mix.Tasks.Db.SlowTimeout do
  import Mix.Ecto
  alias ElixirBackend.Repo
  # use Ecto.Repo, otp_app: :elixir_backend

  @shortdoc "Example, how to enable slow timeout for specific DB tasks"

  @moduledoc """
  * mix db.slow_timeout
  """
  use Mix.Task
  def run(args) do

    System.put_env("slow_timeout", "1000000000")
    ensure_started(ElixirBackend.Repo, [])
    posts = ElixirBackend.Post.get_first()
    IO.inspect posts
  end
end
