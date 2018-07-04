defmodule Mix.Tasks.MultiDb do
  import Mix.Ecto
  alias ElixirBackend.Repo
  # use Ecto.Repo, otp_app: :elixir_backend

  @shortdoc "Example, how to switch between databases on runtime"

  @moduledoc """
  * MIX_ENV=staging mix multi_db
  """
  use Mix.Task
  def run(args) do
    exit 'MIX_ENV=staging mix multi_db'
  end
end
