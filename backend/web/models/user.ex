defmodule ElixirBackend.User do
  use ElixirBackend.Web, :model
  schema "user" do
    field(:name, :string)
    field(:surname, :string)
  end
end
