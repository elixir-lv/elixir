defmodule Backend.IncrementalSlug do

  @moduledoc """
  Provide unique slugs by appending an increment if the slugs has already been used.

  Uses [github.com/h4cc/slugger](https://github.com/h4cc/slugger)
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Backend.Repo

  @incremental_slug Application.get_env(:backend, :incremental_slug)

  @doc """
  Get a unique slug, by convertig the passed value (fromField), and put it in the changeset's :toField.
  """
  def put(changeset, module, fromField \\ @incremental_slug.from_field, toField \\ @incremental_slug.to_field)
  def put(changeset, module, fromField, toField) when is_nil(changeset) or is_nil(module), do: changeset
  def put(changeset, module, fromField, toField), do: getSlugFromField(changeset, module, fromField, toField) |> putSlug(changeset, toField)

  @doc """
  Get a unique slug by convertig the passed value (fromField).
  """
  def getSlugFromField(changeset, module, fromField \\ @incremental_slug.from_field, toField \\ @incremental_slug.to_field)
  def getSlugFromField(changeset, module, fromField, toField), do: get_change(changeset, fromField) |> getUniq(get_change(changeset, :id), module, toField)

  @doc """
  Get a unique slug.
  """
  def getUniq(string, id, module, toField \\ @incremental_slug.to_field)
  def getUniq(string, id, module, toField) when is_nil(string) or id == 0 or is_nil(module), do: nil
  def getUniq(string, id, module, toField), do: string |> getSlug |> makeSlugUnique(id, module, toField)

  @doc """
  Make sure that the passed slug will be unique.
  """
  def makeSlugUnique(slug, id, module, toField \\ @incremental_slug.to_field)
  def makeSlugUnique(slug, id, module, toField), do: isTaken(slug, id, module, toField) |> makeSlugUnique(slug, id, module, toField)
  def makeSlugUnique(taken, slug, id, module, toField) when taken === true, do: getIncrement(slug, id, module, toField) |> concat(slug)
  def makeSlugUnique(taken, slug, id, module, toField), do: slug

  @doc """
  Append the increment to the string.

      iex> Backend.IncrementalSlug.concat(7, "Some-title")
      "Some-title-7"

      iex> Backend.IncrementalSlug.concat(123, "Hey")
      "Hey-123"
  """
  @spec concat(increment :: integer, string :: String.t()) :: String.t()
  def concat(increment, string), do: "#{string}-#{increment}"

  @doc """
  Get a slug that is genererated from the passed string.

  Trim and then pass it to [`Slugger.slugify()`](https://github.com/h4cc/slugger)

  ## Examples

      iex> Backend.IncrementalSlug.getSlug("Some title")
      "Some-title"

      iex> Backend.IncrementalSlug.getSlug(" z e ā Č Ф А - Б В Г	Д š \ / * ^ % ! + ) |")
      "z-e-a-C-F-A-B-V-GD-s-or"
  """
  @spec getSlug(string :: nil) :: nil
  def getSlug(string) when is_nil(string), do: nil

   @spec getSlug(string :: String.t()) :: String.t()
  def getSlug(string), do: string |> String.trim() |> Slugger.slugify()

  @doc """
  Check if another item has taken this slug.
  """
  def isTaken(string, id, module, toField \\ @incremental_slug.to_field)
  def isTaken(string, id, module, toField) when is_nil(string) or id == 0 or is_nil(module), do: nil
  def isTaken(string, id, module, toField), do: getCount(string, id, module, toField) > 0

  @doc """
  Get the count of how many items has used this slug (with or without an increment).
  """
  def getCount(string, id, module, toField \\ @incremental_slug.to_field)
  def getCount(string, id, module, toField), do: module |> select(count("*")) |> limit(1) |> where([a], field(a, ^toField) == ^string) |> exlcudeSelf(id) |> Repo.one

  @doc """
  Do not include the current item when looking for item's that has used this slug.
  """
  def exlcudeSelf(query, id) when is_nil(id), do: query
  def exlcudeSelf(query, id), do: query |> where([a], a.id != ^id)

  @doc """
  Get the increment to add to the slug so it would be unique.
  """
  def getIncrement(string, id, module, toField \\ @incremental_slug.to_field)
  def getIncrement(string, id, module, toField), do: getLastIncrement(string, id, module, toField) |> getIncrement
  def getIncrement(lastIncrement), do: lastIncrement + 1

  @doc """
  Get the increment from the last item with this slug. Like post-1 increment is 1.
  If no item can be found then 0 will be returned.
  """
  def getLastIncrement(string, id, module, toField \\ @incremental_slug.to_field)
  def getLastIncrement(string, id, module, toField), do: find(string, id, module, toField) |> getLastIncrement
  def getLastIncrement(string) when is_nil(string), do: 0
  def getLastIncrement(string), do: string |> String.split("-") |> List.last() |> String.to_integer

  def find(string, id, module, toField \\ @incremental_slug.to_field)
  def find(string, id, module, toField) when is_nil(string) or id == 0 or is_nil(module), do: nil
  def find(string, id, module, toField), do: module |> selectField(toField) |> whereFieldWithIncrement(string, toField) |> exlcudeSelf(id) |> findLast(toField)

  def selectField(module, toField \\ @incremental_slug.to_field)
  def selectField(module, toField), do: module |> select([a], field(a, ^toField))

  @doc """
  Search for this slug that ends with '-' and exactly 1 character.
  See https://dev.mysql.com/doc/refman/8.0/en/pattern-matching.html
  """
  def whereFieldWithIncrement(query, string, toField \\ @incremental_slug.to_field)
  def whereFieldWithIncrement(query, string, toField), do: query |> where([a], like(field(a, ^toField), ^"#{string}-_"))

  def findLast(query, toField \\ @incremental_slug.to_field)
  def findLast(query, toField), do: query |> order_by(desc: ^toField) |> limit(1)  |> Repo.one

  def putSlug(string, changeset, toField \\ @incremental_slug.to_field), do: changeset |> put_change(toField, string)
end
