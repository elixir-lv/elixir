defmodule Backend.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  @timestamps_opts [type: :naive_datetime, usec: false]
  schema "posts" do
    field(:title, :string)
    field(:uri, :string)
    field(:img, :string, default: nil)
    field(:rating, :integer, default: 0)
    field(:text, :string, default: nil)

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :uri, :img, :rating, :text])
    |> Backend.IncrementalSlug.put(__MODULE__, :title, :uri)
    |> validate_required([:title, :uri])
  end

end
