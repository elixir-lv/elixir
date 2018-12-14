defmodule Backend.IncrementalSlug do

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Backend.Repo

  @fromField Application.get_env(:backend, :incremental_slug_from_field, :title)
  @toField Application.get_env(:backend, :incremental_slug_to_field, :slug)

  def put(changeset, module, fromField \\ @fromField, toField \\ @toField)
  def put(changeset, module, fromField, toField) when is_nil(changeset) or is_nil(module), do: changeset
  def put(changeset, module, fromField, toField), do: getSlugFromField(changeset, module, fromField, toField) |> putSlug(changeset, toField)

  def getSlugFromField(changeset, module, fromField \\ @fromField, toField \\ @toField)
  def getSlugFromField(changeset, module, fromField, toField), do: get_change(changeset, fromField) |> getUniq(get_change(changeset, :id), module, toField)

  def getUniq(string, id, module, toField \\ @toField)
  def getUniq(string, id, module, toField) when is_nil(string) or id == 0 or is_nil(module), do: nil
  def getUniq(string, id, module, toField), do: string |> getSlug |> getUniqSlug(id, module, toField)

  def getUniqSlug(string, id, module, toField \\ @toField)
  def getUniqSlug(string, id, module, toField), do: isTaken(string, id, module, toField) |> getUniqSlug(string, id, module, toField)
  def getUniqSlug(taken, string, id, module, toField) when taken === true, do: getIncrement(string, id, module, toField) |> concat(string)
  def getUniqSlug(taken, string, id, module, toField), do: string

  def concat(increment, string), do: "#{string}-#{increment}"

  def getSlug(string) when is_nil(string), do: nil
  def getSlug(string), do: string |> String.trim() |> Slugger.slugify()

  # First check if exist any post with this URI, that is not this post itself.
  def isTaken(uri, id, module, toField \\ @toField)
  def isTaken(uri, id, module, toField) when is_nil(uri) or id == 0 or is_nil(module), do: nil
  def isTaken(uri, id, module, toField), do: getCount(uri, id, module, toField) > 0

  def getCount(uri, id, module, toField \\ @toField)
  def getCount(uri, id, module, toField), do: module |> select(count("*")) |> limit(1) |> where([a], field(a, ^toField) == ^uri) |> exlcudeSelf(id) |> Repo.one

  def exlcudeSelf(query, id) when is_nil(id), do: query
  def exlcudeSelf(query, id), do: query |> where([a], a.id != ^id)

  # Check if any URI with an increment part already exist for this URI.
  # This is required to correctly increment the URI otherwise there will be duplicates.
  def getIncrement(string, id, module, toField \\ @toField)
  def getIncrement(string, id, module, toField), do: getLastIncrement(string, id, module, toField) |> getIncrement
  def getIncrement(lastIncrement), do: lastIncrement + 1

  # Check if any URI with an increment part already exist for this URI.
  # This is required to correctly increment the URI otherwise there will be duplicates.
  def getLastIncrement(string, id, module, toField \\ @toField)
  def getLastIncrement(string, id, module, toField), do: find(string, id, module, toField) |> getLastIncrement
  def getLastIncrement(string) when is_nil(string), do: 0
  def getLastIncrement(string), do: string |> String.split("-") |> List.last() |> String.to_integer

  # Search for this URI that ends with '-' and exactly 1 character.
  # See https://dev.mysql.com/doc/refman/8.0/en/pattern-matching.html
  def find(string, id, module, toField \\ @toField)
  def find(string, id, module, toField) when is_nil(string) or id == 0 or is_nil(module), do: nil
  def find(string, id, module, toField), do: module |> selectField(toField) |> whereFieldWithIncrement(string, toField) |> exlcudeSelf(id) |> findLast(toField)

  def selectField(module, toField \\ @toField)
  def selectField(module, toField), do: module |> select([a], field(a, ^toField))

  def whereFieldWithIncrement(query, string, toField \\ @toField)
  def whereFieldWithIncrement(query, string, toField), do: query |> where([a], like(field(a, ^toField), ^"#{string}-_"))

  def findLast(query, toField \\ @toField)
  def findLast(query, toField), do: query |> order_by(desc: ^toField) |> limit(1)  |> Repo.one

  def putSlug(string, changeset, toField \\ @toField), do: changeset |> put_change(toField, string)
end
