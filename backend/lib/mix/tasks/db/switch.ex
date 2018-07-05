defmodule Mix.Tasks.Db.Switch do
  import Mix.Ecto
  alias ElixirBackend.Repo
  # use Ecto.Repo, otp_app: :elixir_backend

  @shortdoc "Example, how to switch between databases on runtime"

  @moduledoc """
  * MIX_ENV=staging mix db.switch
  """
  use Mix.Task
  def run(args) do

    System.put_env("db_name", "elixir_2")
    ensure_started(ElixirBackend.Repo, [])
    posts = ElixirBackend.Post.get_first()
    # [error] Mariaex.Protocol (#PID<0.207.0>) failed to connect: ** (Mariaex.Error) (1049): Unknown database 'elixir_2'
  end
end
