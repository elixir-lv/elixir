defmodule Mix.Tasks.MultiDb do
  import Mix.Ecto

  @shortdoc "Example, how to switch between databases on runtime"

  @moduledoc """
  * mix multi_db
  """
  use Mix.Task

  def run(args) do
    exit 'multi_db'
  end
end
