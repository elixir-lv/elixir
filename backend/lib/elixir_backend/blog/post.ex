defmodule ElixirBackend.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset


  schema "posts" do
    field :title, :string
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :user_id])
    |> validate_required([:title, :user_id])
  end
end
