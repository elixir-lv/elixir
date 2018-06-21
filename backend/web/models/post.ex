defmodule ElixirBackend.Post do
  use ElixirBackend.Web, :model
  schema "post" do
    field(:title, :string)
  end
end
