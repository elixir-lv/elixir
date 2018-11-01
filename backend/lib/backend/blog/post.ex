defmodule Backend.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset


  @timestamps_opts [type: :naive_datetime, usec: false]
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
		|> createUniqueUriFromTitle()
    |> validate_required([:title, :uri])
  end

	def createUniqueUriFromTitle(nil), do: nil
	def createUniqueUriFromTitle(changeset) do
    get_change(changeset, :title) |> createUniqueUriFromString(changeset)
	end

	def createUniqueUriFromString(string, changeset) do
		uri = getUriFromString(string)
    changeset |> put_change(:uri, uri)
	end

	def getUriFromString(nil), do: nil
  def getUriFromString(string) do
    string |> String.trim() |> Slugger.slugify()
	end

end
