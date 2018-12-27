defmodule Backend.Blog.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :naive_datetime, usec: false]
  schema "blog_category" do
    field(:title, :string)
    field(:slug, :string)
    field(:img, :string, default: nil)
    field(:rating, :integer, default: 0)
    field(:text, :string, default: nil)

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:title, :slug, :img, :rating, :text])
    |> IncrementalSlug.put(__MODULE__, :title, :slug)
    |> validate_required([:title, :slug])
  end
end