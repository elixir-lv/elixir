defmodule Backend.IncrementalSlug do

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Backend.Repo

  # @fromField Application.get_env(:incremental_slug, :from_field, :title)
  # @toField Application.get_env(:incremental_slug, :to_field, :slug)

  def put(changeset, module, fromField, toField) when is_nil(changeset) or is_nil(module), do: changeset
  def put(changeset, module, fromField, toField), do: getSlugFromField(changeset, module, fromField, toField) |> putSlug(changeset, toField)

  def getSlugFromField(changeset, module, fromField, toField), do: get_change(changeset, fromField) |> getUniq(get_change(changeset, :id), toField, module)

  def getUniq(string, id, toField, module) when is_nil(string) or id == 0 or is_nil(module), do: nil
  def getUniq(string, id, toField, module), do: string |> getSlug |> getUniqSlug(id, toField, module)

  def getUniqSlug(string, id, toField, module), do: isTaken(string, id, module, toField) |> getUniqSlug(string, id, toField, module)
  def getUniqSlug(taken, string, id, toField, module) when taken === true, do: getIncrement(string, id, toField, module) |> concat(string)
  def getUniqSlug(taken, string, id, toField, module), do: string

  def concat(increment, string), do: "#{string}-#{increment}"

  def getSlug(string) when is_nil(string), do: nil
  def getSlug(string), do: string |> String.trim() |> Slugger.slugify()

  # First check if exist any post with this URI, that is not this post itself.
  def isTaken(uri, id, module, toField \\ :slug)
  def isTaken(uri, id, module, toField) when is_nil(uri) or id == 0 or is_nil(module), do: nil
  def isTaken(uri, id, module, toField), do: getCount(uri, id, toField, module) > 0

  def getCount(uri, id, toField, module), do: module |> select(count("*")) |> limit(1) |> where([a], field(a, ^toField) == ^uri) |> exlcudeSelf(id) |> Repo.one

  def exlcudeSelf(query, id) when is_nil(id), do: query
  def exlcudeSelf(query, id), do: query |> where([a], a.id != ^id)

  # Check if any URI with an increment part already exist for this URI.
  # This is required to correctly increment the URI otherwise there will be duplicates.
  def getIncrement(string, id, toField, module), do: getLastIncrement(string, id, toField, module) |> getIncrement
  def getIncrement(lastIncrement), do: lastIncrement + 1

  # Check if any URI with an increment part already exist for this URI.
  # This is required to correctly increment the URI otherwise there will be duplicates.
  def getLastIncrement(string, id, toField, module), do: find(string, id, toField, module) |> getLastIncrement
  def getLastIncrement(string) when is_nil(string), do: 0
  def getLastIncrement(string), do: string |> String.split("-") |> List.last() |> String.to_integer

  # Search for this URI that ends with '-' and exactly 1 character.
  # See https://dev.mysql.com/doc/refman/8.0/en/pattern-matching.html
  def find(string, id, toField, module) when is_nil(string) or id == 0 or is_nil(module), do: nil
  def find(string, id, toField, module), do: module |> selectField(toField) |> whereFieldWithIncrement(string, toField) |> exlcudeSelf(id) |> findLast(toField)
  def selectField(module, toField), do: module |> select([a], field(a, ^toField))
  def whereFieldWithIncrement(query, string, toField), do: query |> where([a], like(field(a, ^toField), ^"#{string}-_"))
  def findLast(query, toField), do: query |> order_by(desc: ^toField) |> limit(1)  |> Repo.one

  def putSlug(string, changeset, toField), do: changeset |> put_change(toField, string)
end
