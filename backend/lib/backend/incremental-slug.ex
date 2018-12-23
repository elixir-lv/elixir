defmodule Backend.IncrementalSlug do
  @moduledoc """
  Store a unique slug.

  Append an increment (1-10), if this slug is already taken.

  ## Depends on

  * [github.com/h4cc/slugger](https://github.com/h4cc/slugger)

  ## Defaults are defined in

  ```ex
  config :backend, incremental_slug: %{from_field: :title, to_field: :uri}
  ```
  but can be overwiiten on the fly when calling a method.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Backend.Repo

  @incremental_slug Application.get_env(:backend, :incremental_slug)

  @doc """
  Append the increment to the slug.

      iex> "Some-title" |> Backend.IncrementalSlug.append(7)
      "Some-title-7"

      iex> "Hey" |> Backend.IncrementalSlug.append(123)
      "Hey-123"
  """
  @spec append(slug :: String.t(), increment :: integer) :: String.t()
  def append(slug, increment), do: "#{slug}-#{increment}"

  @doc """
  Exclude this ID from the query.

  ## Parameters

  * `queryable` - Check the table to see if the generated slug is already taken.
  * `id` - Queryable item's ID. Required when looking if another item has the same slug.

  ## Examples

      iex> alias Backend.{Blog.Post, IncrementalSlug, Repo}
      iex> import Ecto.Query, warn: false

      iex> query = Post |> select(count("*")) |> limit(1)
      #Ecto.Query<from p in Backend.Blog.Post, limit: 1, select: count("*")>

      iex> IncrementalSlug.exlcudeID(query, nil)
      #Ecto.Query<from p in Backend.Blog.Post, limit: 1, select: count("*")>

      iex> IncrementalSlug.exlcudeID(query, 123)
      #Ecto.Query<from p in Backend.Blog.Post, where: p.id != ^123, limit: 1,  select: count("*")>
  """
  @spec exlcudeID(queryable :: Ecto.Queryable.t(), id :: integer()) :: Ecto.Query.t()
  def exlcudeID(queryable, id) when is_nil(id), do: queryable
  def exlcudeID(queryable, id), do: queryable |> where([a], a.id != ^id)

  @doc """
  Find the taken slug. It may contain an increment.

  ## Parameters

  * `slug` - A regular slug without an increment.
  * `id` - Queryable item's ID. Required when looking if another item has the same slug.
  * `queryable` - Check the table to see if the generated slug is already taken.
  * `to` - In which changeset's field put the generated slug?

  ## Return value

   The slug with an increment or `nil`.

   In case, if multiple items were found, return the one with the greatest increment.

  ## Examples

      iex> alias Backend.{Blog.Post, IncrementalSlug, Repo}

      iex> IncrementalSlug.find("Some-title", nil, Post)
      nil

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 1, title: "Some title", slug: "Some-title"}

      iex> IncrementalSlug.find("Some-title", nil, Post)
      nil

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 2, title: "Some title", slug: "Some-title-1"}

      iex> IncrementalSlug.find("Some-title", nil, Post)
      "Some-title-1"

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 3, title: "Some title", slug: "Some-title-2"}

      iex> IncrementalSlug.find("Some-title", nil, Post)
      "Some-title-2"
  """
  @spec find(slug :: String.t(), id :: integer(), queryable :: Ecto.Queryable.t(), to :: atom()) ::
          String.t() | nil
  @spec find(slug :: nil, id :: integer(), queryable :: Ecto.Queryable.t(), to :: atom()) :: nil
  @spec find(slug :: String.t(), id :: 0, queryable :: Ecto.Queryable.t(), to :: atom()) :: nil
  @spec find(slug :: String.t(), id :: integer(), queryable :: nil, to :: atom()) :: nil
  def find(slug, id, queryable, to \\ @incremental_slug.to_field)
  def find(slug, id, queryable, to) when is_nil(slug) or id == 0 or is_nil(queryable), do: nil

  def find(slug, id, queryable, to),
    do:
      queryable
      |> selectField(to)
      |> whereFieldWithIncrement(slug, to)
      |> exlcudeID(id)
      |> findLast(to)

  @doc """
  Find the last item.

  ## Parameters

  * `queryable` - Any query - look for items or a count.
  * `to` - In which changeset's field put the generated slug?

  ## Examples

      iex> alias Backend.{Blog.Post, IncrementalSlug, Repo}

      iex> IncrementalSlug.findLast(Post)
      nil

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 1, slug: "Some-title"}

      iex> IncrementalSlug.findLast(Post)
      %Post{id: 1, slug: "Some-title"}

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 2, slug: "Some-title-1"}

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 3, slug: "Some-title-2"}

      iex> IncrementalSlug.findLast(Post)
      %Post{id: 3, slug: "Some-title-2"}
  """
  @spec findLast(queryable :: Ecto.Queryable.t(), atom()) :: Ecto.Schema.t() | nil
  def findLast(queryable, to \\ @incremental_slug.to_field)
  def findLast(queryable, to), do: queryable |> order_by(desc: ^to) |> limit(1) |> Repo.one()

  @doc """
  Get the count of how many items have taken this exact slug.

  ## Parameters

  * `slug` - A regular slug without an increment.
  * `id` - Queryable item's ID. Required when looking if another item has the same slug.
  * `queryable` - Check the table to see if the generated slug is already taken.
  * `to` - In which changeset's field put the generated slug?

  ## Examples

      iex> alias Backend.{Blog.Post, IncrementalSlug, Repo}

      iex> IncrementalSlug.getCount("Some-title", nil, Post)
      0

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 1, title: "Some title", slug: "Some-title"}

      iex> IncrementalSlug.getCount("Some-title", nil, Post)
      1

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 2, title: "Some title", slug: "Some-title-1"}

      iex> IncrementalSlug.getCount("Some-title", nil, Post)
      1
  """
  @spec getCount(
          slug :: String.t(),
          id :: integer(),
          queryable :: Ecto.Queryable.t(),
          to :: atom()
        ) :: integer()
  def getCount(slug, id, queryable, to \\ @incremental_slug.to_field)

  def getCount(slug, id, queryable, to),
    do:
      queryable
      |> select(count("*"))
      |> limit(1)
      |> where([a], field(a, ^to) == ^slug)
      |> exlcudeID(id)
      |> Repo.one()

  @doc """
  Find an increment that can make this slug unique.

  ## Parameters

  * `slug` - A regular slug without an increment.
  * `id` - Queryable item's ID. Required when looking if another item has the same slug.
  * `queryable` - Check the table to see if the generated slug is already taken.
  * `to` - In which changeset's field put the generated slug?

  ## Return value

  The greatest increment `+1` or `1` if the slug is not taken.

  ## Useful to know

  `10` is the greatest available increment. See why in `whereFieldWithIncrement/3`.

  ## Examples

      iex> alias Backend.{Blog.Post, IncrementalSlug, Repo}

      iex> IncrementalSlug.getIncrement("Some-title", nil, Post)
      1

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 1, title: "Some title", slug: "Some-title"}

      iex> IncrementalSlug.getIncrement("Some-title", nil, Post)
      1

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 2, title: "Some title", slug: "Some-title-1"}

      iex> IncrementalSlug.getIncrement("Some-title", nil, Post)
      2
  """
  @spec getIncrement(
          slug :: String.t(),
          id :: integer(),
          queryable :: Ecto.Queryable.t(),
          to :: atom()
        ) :: integer()
  def getIncrement(slug, id, queryable, to \\ @incremental_slug.to_field)

  def getIncrement(slug, id, queryable, to),
    do: getLastIncrement(slug, id, queryable, to) |> getIncrement

  @doc false
  @spec getIncrement(lastIncrement :: integer()) :: integer()
  defp getIncrement(lastIncrement), do: lastIncrement + 1

  @doc """
  Find the greatest increment from the items that have taken this slug.

  ## Parameters

  * `slug` - A regular slug without an increment.
  * `id` - Queryable item's ID. Required when looking if another item has the same slug.
  * `queryable` - Check the table to see if the generated slug is already taken.
  * `to` - In which changeset's field put the generated slug?

  ## Return value

  The greatest increment or `0` if the slug is not taken.

  ## Useful to know

  `9` is the greatest increment that can be found. See why in `whereFieldWithIncrement/3`.

  ## Examples

      iex> alias Backend.{Blog.Post, IncrementalSlug, Repo}

      iex> IncrementalSlug.getLastIncrement("Some-title", nil, Post)
      0

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 1, title: "Some title", slug: "Some-title"}

      iex> IncrementalSlug.getLastIncrement("Some-title", nil, Post)
      0

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 2, title: "Some title", slug: "Some-title-1"}

      iex> IncrementalSlug.getLastIncrement("Some-title", nil, Post)
      1
  """
  @spec getLastIncrement(
          slug :: String.t(),
          id :: integer(),
          queryable :: Ecto.Queryable.t(),
          to :: atom()
        ) :: integer()
  def getLastIncrement(slug, id, queryable, to \\ @incremental_slug.to_field)

  def getLastIncrement(slug, id, queryable, to),
    do: find(slug, id, queryable, to) |> getLastIncrement

  @doc """
  Extract an increment from the slug.

  ## Parameters

  * `slug` - A slug with an increment.

  ## Return value

  The Increment or `0`.

  ## Examples

      iex> alias Backend.IncrementalSlug
      iex> IncrementalSlug.getLastIncrement(nil)
      0
      iex> IncrementalSlug.getLastIncrement("Some-title-1")
      1
      iex> IncrementalSlug.getLastIncrement("Some-title-5")
      5
  """
  @spec getLastIncrement(slug | nil :: String.t()) :: integer
  def getLastIncrement(slug) when is_nil(slug), do: 0
  def getLastIncrement(slug), do: slug |> String.split("-") |> List.last() |> String.to_integer()

  @doc """
  Get a slug from the passed string.

  Trim and pass it to [`Slugger.slugify/2`](https://github.com/h4cc/slugger)

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
  Get a unique slug from the selected changeset's field.

  ## Parameter

  * `changeset` - Take the value from a field, and put back the slug in another.
  * `queryable` - Check the table to see if the generated slug is already taken.
  * `from` - From which changeset's field generate the slug?
  * `to` - In which changeset's field put the generated slug?

  ## Examples

      iex> alias Backend.{Blog.Post, IncrementalSlug, Repo}

      iex> changeset = Post.changeset(%Post{}, %{title: "Some title"})
      iex> changeset |> IncrementalSlug.getSlugFromField(Post)
      "Some-title"

      iex> post = changeset |> Repo.insert!()
      %Post{id: 1, title: "Some title", slug: "Some-title"}

      iex> changeset |> IncrementalSlug.getSlugFromField(Post)
      "Some-title-1"
  """
  @spec getSlugFromField(
          changeset :: Ecto.Changeset.t(),
          queryable :: Ecto.Queryable.t(),
          from :: atom(),
          to :: atom()
        ) :: String.t()
  def getSlugFromField(
        changeset,
        queryable,
        from \\ @incremental_slug.from_field,
        to \\ @incremental_slug.to_field
      )

  def getSlugFromField(changeset, queryable, from, to),
    do: get_change(changeset, from) |> getUnique(get_change(changeset, :id), queryable, to)

  @doc """
  Get a unique slug from a string.

  ## Parameter

  * `string` - String from which generate the slug.
  * `id` - Queryable item's ID. Required when looking if another item has the same slug.
  * `queryable` - Check the table to see if the generated slug is already taken.
  * `to` - In which changeset's field put the generated slug?

  ## Return value

  A slug (with an increment, if it was taken).

  ## Examples

      iex> alias Backend.{Blog.Post, IncrementalSlug, Repo}

      iex> IncrementalSlug.getUnique("Some title", nil, Post)
      "Some-title"

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 1, title: "Some title", slug: "Some-title"}

      iex> IncrementalSlug.getUnique("Some title", nil, %Post{})
      "Some-title-1"
  """
  @spec getUnique(
          string :: String.t(),
          id :: integer(),
          queryable :: Ecto.Queryable.t(),
          to :: atom()
        ) :: String.t()
  def getUnique(string, id, queryable, to \\ @incremental_slug.to_field)

  def getUnique(string, id, queryable, to) when is_nil(string) or id == 0 or is_nil(queryable),
    do: nil

  def getUnique(string, id, queryable, to),
    do: string |> getSlug |> makeSlugUnique(id, queryable, to)

  @doc """
  Check if another item has taken this slug.

  ## Parameters

  * `slug` - A regular slug without an increment.
  * `id` - Queryable item's ID. Required when looking if another item has the same slug.
  * `queryable` - Check the table to see if the generated slug is already taken.
  * `to` - In which changeset's field put the generated slug?

  ## Examples

      iex> alias Backend.{Blog.Post, IncrementalSlug, Repo}

      iex> IncrementalSlug.isTaken("Some-title", nil, Post)
      false

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 1, title: "Some title", slug: "Some-title"}

      iex> IncrementalSlug.isTaken("Some-title", nil, Post)
      true
  """
  @spec isTaken(
          slug :: String.t(),
          id :: integer(),
          queryable :: Ecto.Queryable.t(),
          to :: atom()
        ) :: boolean()
  def isTaken(slug, id, queryable, to \\ @incremental_slug.to_field)
  def isTaken(slug, id, queryable, to) when is_nil(slug) or id == 0 or is_nil(queryable), do: nil
  def isTaken(slug, id, queryable, to), do: getCount(slug, id, queryable, to) > 0

  @doc """
  Append an increment (1-10), if this slug is already taken.

  ## Parameters

  * `slug` - A regular slug without an increment.
  * `id` - Queryable item's ID. Required when looking if another item has the same slug.
  * `queryable` - Check the table to see if the generated slug is already taken.
  * `to` - In which changeset's field put the generated slug?

  ## Examples

      iex> alias Backend.{Blog.Post, IncrementalSlug, Repo}

      iex> IncrementalSlug.makeSlugUnique("Some-title", nil, Post)
      "Some-title"

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 1, title: "Some title", slug: "Some-title"}

      iex> IncrementalSlug.makeSlugUnique("Some-title", nil, Post)
      "Some-title-1"
  """
  @spec makeSlugUnique(
          slug :: String.t(),
          id :: integer(),
          queryable :: Ecto.Queryable.t(),
          to :: atom()
        ) :: String.t()
  def makeSlugUnique(slug, id, queryable, to \\ @incremental_slug.to_field)

  def makeSlugUnique(slug, id, queryable, to),
    do: isTaken(slug, id, queryable, to) |> makeSlugUniqueIfTaken(slug, id, queryable, to)

  @doc """
  Append an increment (1-10), if this slug is already taken.

  ## Parameters

  * `taken` - is this slug already taken?
  * `slug` - A regular slug without an increment.
  * `id` - Queryable item's ID. Required when looking if another item has the same slug.
  * `queryable` - If it is taken, then get the last increment.
  * `to` - In which changeset's field put the generated slug?

  ## Examples

      iex> alias Backend.{Blog.Post, IncrementalSlug, Repo}

      iex> IncrementalSlug.makeSlugUniqueIfTaken(false, "Some-title", nil, Post)
      "Some-title"

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 1, title: "Some title", slug: "Some-title"}

      iex>  IncrementalSlug.makeSlugUniqueIfTaken(false, "Some-title", nil, Post)
      "Some-title"

      iex>  IncrementalSlug.makeSlugUniqueIfTaken(true, "Some-title", nil, Post)
      "Some-title-1"

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 2, title: "Some title", slug: "Some-title-1"}

      iex>  IncrementalSlug.makeSlugUniqueIfTaken(true, "Some-title", nil, Post)
      "Some-title-2"
  """
  @spec makeSlugUniqueIfTaken(
          taken :: boolean(),
          slug :: String.t(),
          id :: integer(),
          queryable :: Ecto.Queryable.t(),
          to :: atom()
        ) :: String.t()
  def makeSlugUniqueIfTaken(taken, slug, id, queryable, to \\ @incremental_slug.to_field)

  def makeSlugUniqueIfTaken(taken, slug, id, queryable, to) when taken === true do
    increment = getIncrement(slug, id, queryable, to)
    slug |> append(increment)
  end

  def makeSlugUniqueIfTaken(taken, slug, id, queryable, to), do: slug

  @doc """
  Generate a slug, add an increment if the slug is taken, and put it in the changeset.

  ## Parameter

  * `changeset` - Take the value from a field, and put back the slug in another.
  * `queryable` - Check the table to see if the generated slug is already taken.
  * `from` - From which changeset's field generate the slug?
  * `to` - In which changeset's field put the generated slug?

  ## Return values

  If everything went well, then return the same changeset with a new slug, otherwise without.

  ## Examples

      iex> alias Backend.{Blog.Post, IncrementalSlug, Repo}

      iex> changeset = Post.changeset(%Post{}, %{title: "Some title"}) |> IncrementalSlug.put(Post)
      iex> post = changeset |> Repo.insert!()
      %Post{id: 1, title: "Some title", slug: "Some-title"}

      iex> changeset2 = Post.changeset(%Post{}, %{title: "Some title"}) |> IncrementalSlug.put(Post)
      iex> post2 = changeset2 |> Repo.insert!()
      %Post{id: 2, title: "Some title", slug: "Some-title-1"}
  """
  @spec put(
          changeset :: Ecto.Changeset.t() | nil,
          queryable :: Ecto.Queryable.t() | nil,
          from :: atom(),
          to :: atom()
        ) :: Ecto.Changeset.t()
  def put(
        changeset,
        queryable,
        from \\ @incremental_slug.from_field,
        to \\ @incremental_slug.to_field
      )

  def put(changeset, queryable, from, to) when is_nil(changeset) or is_nil(queryable),
    do: changeset

  def put(changeset, queryable, from, to),
    do: getSlugFromField(changeset, queryable, from, to) |> putSlug(changeset, to)

  @doc """
  Put this slug into the selected changeset's field.

  ## Parameters

  * `slug` - A regular slug without an increment.
  * `changeset` - Take the value from a field, and put back the slug in another.
  * `to` - In which changeset's field put the generated slug?

  ## Examples

      iex> alias Backend.{Blog.Post, IncrementalSlug, Repo}
      iex> changeset = Post.changeset(%Post{}, %{title: "Some title"})
      iex> changeset2 = "Some-slug" |> IncrementalSlug.putSlug(changeset)
      iex> changeset2.changes
      %{title: "Some title", uri: "Some-slug"},
  """
  @spec putSlug(slug :: String.t(), changeset :: Ecto.Changeset.t(), to :: atom()) ::
          Ecto.Changeset.t()
  def putSlug(slug, changeset, to \\ @incremental_slug.to_field),
    do: changeset |> put_change(to, slug)

  @doc """
  Specify the slug field in a query.

  ## Parameters

  * `queryable` - Check the table to see if the generated slug is already taken.
  * `to` - In which changeset's field put the generated slug?

  ## Return value

  Query with selected field.

  ## Examples

      iex> alias Backend.{Blog.Post, IncrementalSlug}

      iex> IncrementalSlug.selectField(Post, :slug)
      #Ecto.Query<from p in Backend.Blog.Post, select: p.slug>

      iex> IncrementalSlug.selectField(Post, :uri)
      #Ecto.Query<from p in Backend.Blog.Post, select: p.uri>
  """
  @spec selectField(queryable :: Ecto.Queryable.t(), to :: atom()) :: Ecto.Query.t()
  def selectField(queryable, to \\ @incremental_slug.to_field)
  def selectField(queryable, to), do: queryable |> select([a], field(a, ^to))

  @doc """
  Search for this slug that ends with '-' and exactly 1 character.

  See https://dev.mysql.com/doc/refman/8.0/en/pattern-matching.htm

  ## Parameters

  * `queryable` - Any query - look for items or a count.
  * `slug` - A regular slug without an increment.
  * `to` - In which changeset's field put the generated slug?

  ## Return value

  Query with WHERE LIKE condfition.

  ## Examples

      iex> alias Backend.{Blog.Post, IncrementalSlug}

      iex> IncrementalSlug.whereFieldWithIncrement(Post, "Some-title")
      #Ecto.Query<from p in Backend.Blog.Post, where: like(p.uri, ^"Some-title-_")>

      iex> IncrementalSlug.whereFieldWithIncrement(Post, "Hello-there")
      #Ecto.Query<from p in Backend.Blog.Post, where: like(p.uri, ^"Hello-there-_")>
  """
  @spec whereFieldWithIncrement(queryable :: Ecto.Queryable.t(), slug :: String.t(), atom()) ::
          Ecto.Query.t()
  def whereFieldWithIncrement(queryable, slug, to \\ @incremental_slug.to_field)

  def whereFieldWithIncrement(queryable, slug, to),
    do: queryable |> where([a], like(field(a, ^to), ^"#{slug}-_"))
end
