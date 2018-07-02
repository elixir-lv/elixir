defmodule Mix.Tasks.User do

  # mix help | grep user
  @shortdoc "Extract user's last name from the passed full name."

  # mix help user
  @moduledoc """
  Arguments:
  * n - full name (String, Required).
  * f - should write output to file (Boolean)

  * mix user -n Janis Rullis
  * mix user -n Janis Rullis -f true

  From https://www.learnelixir.tv/episodes/10-mix
  """

  use Mix.Task

  def run(args) do
    {opts, _, _} = OptionParser.parse(args, aliases: [n: :full_name, f: :must_write_to_file])
    user = %User{email: nil, name: opts[:full_name]}
    last_name = User.last_name(user);
    IO.puts last_name

    if(opts[:must_write_to_file]) do
      IO.puts File.write("/app/storage/logs/user.log", last_name, [:append])
    end
  end
end
