defmodule Backend.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset


  schema "posts" do
    field :title, :string
		field :uri, :string
		field :img, :string, default: nil
		field :rating, :integer, default: 0
		field :text, :string, default: nil

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :uri, :img, :rating, :text])
		|> getUriFromTitle()
    |> validate_required([:title, :uri])
  end

  defp getUriFromTitle(changeset) do
    title = get_change(changeset, :title)
		uri = getUriFromString(title)
    changeset = changeset |> put_change(:uri, uri)
  end

	def getUriFromString(nil), do: nil
	def getUriFromString(string) do
		Slugger.slugify(string)
	end

end
