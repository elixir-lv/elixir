defmodule IncrementalSlug.TestPost do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "test_posts" do
    field(:title, :string)
    field(:slug, :string)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :slug])
    |> IncrementalSlug.put(__MODULE__, :title, :slug)
    |> validate_required([:title, :slug])
  end

  def truncate(), do: "TRUNCATE test_posts RESTART IDENTITY;" |> IncrementalSlug.TestRepo.query
end
