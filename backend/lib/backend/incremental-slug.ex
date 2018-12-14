defmodule Backend.IncrementalSlug do

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Backend.Repo

  def createUniqueUriFromTitle(changeset, module) when is_nil(changeset) or is_nil(module), do: changeset

  def createUniqueUriFromTitle(changeset, module),
    do: get_change(changeset, :title) |> createUniqueUriFromString(changeset, module)

  def createUniqueUriFromString(string, changeset, module) when is_nil(string) or is_nil(changeset) or is_nil(module), do: changeset

  def createUniqueUriFromString(string, changeset, module) do
    uri = getUniqueUriFromString(string, get_change(changeset, :id), module)
    changeset |> put_change(:uri, uri)
  end

  def getUniqueUriFromString(string, id, module) when is_nil(string) or id == 0 or is_nil(module), do: nil

  def getUniqueUriFromString(string, id, module) do
    generatedUri = string |> getUriFromString

    # Get the increment to put at the end if this URI is already taken.
    uri =
      if isURItaken(generatedUri, id, module) === true do
        # Check if any URI with an increment part already exist for this URI.
        # This is required to correctly increment the URI otherwise there will be duplicates.
        uriWithIncrement = getURIWithIncrement(generatedUri, id, module)

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

      uri
  end

  # First check if exist any post with this URI, that is not this post itself.
  def isURItaken(uri, id, module) when is_nil(uri) or id == 0 or is_nil(module), do: nil

  def isURItaken(uri, id, module) do
    query = module |> select(count("*")) |> limit(1) |> where([a], a.uri == ^uri)

    # Avoid looking for this post.
    query = if is_nil(id) === false do
      query |> where([a], a.id != ^id)
    else
      query
    end

    count = query |> Repo.one()
    count > 0
  end

  def getURIWithIncrement(generatedUri, id, module) when is_nil(generatedUri) or id == 0 or is_nil(module), do: nil

  def getURIWithIncrement(generatedUri, id, module) do
    # Search for this URI that ends with '-' and exactly 1 character.
    # See https://dev.mysql.com/doc/refman/8.0/en/pattern-matching.html
    query =
      module
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
end
