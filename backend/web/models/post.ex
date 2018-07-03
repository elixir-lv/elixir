defmodule ElixirBackend.Post do
  use ElixirBackend.Web, :model
  alias  ElixirBackend.User
  schema "post" do
    field(:title, :string)
  end

  def get_first() do
    query = from(a in __MODULE__, join: b in User, on: a.user_id == b.id, limit: 1, select: %{id: a.id, title: a.title, name: b.name, surname: b.surname})
    ElixirBackend.Repo.one(query)
  end
end
