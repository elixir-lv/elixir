defmodule ElixirBackend.Repo do
  use Ecto.Repo, otp_app: :elixir_backend

  def init(_type, config) do

    # Enable a slow timeout
    slow_timeout = System.get_env("slow_timeout")
    if is_nil(slow_timeout) === false do
      slow_timeout_int = String.to_integer(slow_timeout)
      config = config
      |> Keyword.put(:timeout, slow_timeout_int)
      |> Keyword.put(:pool_timeout, slow_timeout_int)
    end

    # Switch DB.
    db_name = System.get_env("db_name")
    if is_nil(db_name) === false do
      config = config |> Keyword.put(:database, db_name)
    end

    {:ok, config}
  end
end
