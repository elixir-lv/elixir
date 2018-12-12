defmodule Backend.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias Backend.Repo

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
    |> createUniqueUriFromTitle()
    |> validate_required([:title, :uri])
  end

  def createUniqueUriFromTitle(changeset) when is_nil(changeset), do: changeset

  def createUniqueUriFromTitle(changeset),
    do: get_change(changeset, :title) |> createUniqueUriFromString(changeset)

  def createUniqueUriFromString(string, changeset) when is_nil(string), do: changeset

  def createUniqueUriFromString(string, changeset) do
    uri = getUniqueUriFromString(string, get_change(changeset, :id))
    changeset |> put_change(:uri, uri)
  end

  def getUniqueUriFromString(string, id) when is_nil(string), do: nil

  def getUniqueUriFromString(string, id) do
    generatedUri = string |> getUriFromString

    # Get the increment to put at the end if this URI is already taken.
    uri =
      if isURItaken(generatedUri, id) === true do
        # Check if any URI with an increment part already exist for this URI.
        # This is required to correctly increment the URI otherwise there will be duplicates.
        uriWithIncrement = getURIWithIncrement(generatedUri, id)

        # Did not find any URI with an increment at the end.
        increment = if is_nil(uriWithIncrement) do
          1
          # Found URI wiht an increment at the end.
        else
          # Increase the incremnet.
          lastIncrement = uriWithIncrement |> String.split("-") |> List.last() |> String.to_integer
          lastIncrement + 1
        end

        "#{generatedUri}-#{increment}"
      else
        # URI is not taken so we can use the one that was generated from the title.
        generatedUri
      end
  end

  # First check if exist any post with this URI, that is not this post itself.
  def isURItaken(uri, id) when is_nil(uri), do: nil

  def isURItaken(uri, id) do
    query = __MODULE__ |> select(count("*")) |> limit(1) |> where([a], a.uri == ^uri)

    # Avoid looking for this post.
    query = if is_nil(id) === false do
      query |> where([a], a.id != ^id)
    else
      query
    end

    count = query |> Repo.one()
    count > 0
  end

  def getURIWithIncrement(generatedUri, id) when is_nil(generatedUri), do: nil

  def getURIWithIncrement(generatedUri, id) do
    # Search for this URI that ends with '-' and exactly 1 character.
    # See https://dev.mysql.com/doc/refman/8.0/en/pattern-matching.html
    query =
      __MODULE__
      |> select([a], a.uri)
      |> limit(1)
      |> where([a], like(a.uri, ^"#{generatedUri}-_"))
      # Collect URIs with a highest increment.
      |> order_by(desc: :uri)
    # Ecto.Adapters.SQL.to_sql(:all, Repo, query) |> IO.inspect

    # Avoid looking for this post.
    query = if is_nil(id) === false do
      query |> where([a], a.id != ^id)
    else
      query
    end

    query |> Repo.one()
  end

  def getUriFromString(string) when is_nil(string), do: nil
  def getUriFromString(string), do: string |> String.trim() |> Slugger.slugify()

  def isDigit(string),
    do:
      %{"1": 1, "2": 1, "3": 1, "4": 1, "5": 1, "6": 1, "7": 1, "8": 1, "9": 1}
      |> Map.has_key?(string |> String.to_atom())
end
