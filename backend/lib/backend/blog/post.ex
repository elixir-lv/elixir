defmodule Backend.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset


  schema "posts" do
    field :title, :string
		field :url, :string
		field :img, :string

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
