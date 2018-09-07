defmodule Backend.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset


  schema "posts" do
    field :title, :string
		field :uri, :string
		field :img, :string
		field :rating, :string
		field :text, :string

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :uri, :img, :rating, :text])
    |> validate_required([:title, :uri, :img, :rating, :text])
  end
end
