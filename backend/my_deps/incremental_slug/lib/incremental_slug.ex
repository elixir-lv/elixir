defmodule IncrementalSlug do

  import Ecto.Query, warn: false
  import Ecto.Changeset
  # alias IncrementalSlug.Repo

  # def repo() do
  #   Application.get_env(:incremental_slug, :repo)
  # end

  @moduledoc """
  Store a unique slug.

  Append an increment (1-10), if this slug is already taken.

  ## Example

  See `put/4`.

  ## Depends on

  * [github.com/h4cc/slugger](https://github.com/h4cc/slugger)

  ## Defaults are defined in

  ```ex
  config :incremental_slug, fields: %{from: :title, to: :slug}
  ```
  but can be overwiiten on the fly when calling a method.
  """

  @incremental_slug Application.get_env(:incremental_slug, :fields, %{from: :title, to: :slug})
  @repo Application.get_env(:incremental_slug, :repo)

  @doc ~S"""
  Append the increment to the slug.

      iex> "Some-title" |> IncrementalSlug.append(7)
      "Some-title-7"

      iex> "Hey" |> IncrementalSlug.append(123)
      "Hey-123"
  """
  @spec append(slug :: String.t(), increment :: integer) :: String.t()
  def append(slug, increment), do: "#{slug}-#{increment}"


  @doc ~S"""
  Exclude this ID from the query.

  ## Examples

      iex> alias {Blog.Post, IncrementalSlug, Repo}
      iex> import Ecto.Query, warn: false

      iex> query = Post |> select(count("*")) |> limit(1)
      #Ecto.Query<from p in Blog.Post, limit: 1, select: count("*")>

      iex> IncrementalSlug.exlcudeID(query, nil)
      #Ecto.Query<from p in Blog.Post, limit: 1, select: count("*")>

      iex> IncrementalSlug.exlcudeID(query, 123)
      #Ecto.Query<from p in Blog.Post, where: p.id != ^123, limit: 1,  select: count("*")>
  """
  @spec exlcudeID(queryable :: Ecto.Queryable.t(), id :: integer()) :: Ecto.Query.t()
  def exlcudeID(queryable, id) when is_nil(id), do: queryable
  def exlcudeID(queryable, id), do: queryable |> where([a], a.id != ^id)

  @doc ~S"""
  Find the taken slug in the database. It may contain an increment.

  ## Parameters

  * `slug` - A regular slug without an increment.
  * `id` - Exclude this ID from the query.
  * `queryable` - In which table to look?
  * `to` - In which column is the slug stored?

  ## Return value

   A slug with an increment or `nil`.

   In case, if multiple items were found, return the one with the greatest increment.

  ## Examples

      iex> alias {Blog.Post, IncrementalSlug, Repo}

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
  def find(slug, id, queryable, to \\ @incremental_slug.to)
  def find(slug, id, queryable, _to) when is_nil(slug) or id == 0 or is_nil(queryable), do: nil

  def find(slug, id, queryable, to),
    do:
      queryable
      |> selectField(to)
      |> whereSlugWithIncrement(slug, to)
      |> exlcudeID(id)
      |> findItemWithGreatestIncrement(to)

  @doc ~S"""
  Find the item that has the slug with a greatest increment.

  ## Parameters

  * `queryable` - In which table to look?
  * `to` - In which column is the slug stored?

  ## Examples

      iex> alias {Blog.Post, IncrementalSlug, Repo}

      iex> IncrementalSlug.findItemWithGreatestIncrement(Post)
      nil

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 1, slug: "Some-title"}

      iex> IncrementalSlug.findItemWithGreatestIncrement(Post)
      %Post{id: 1, slug: "Some-title"}

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 2, slug: "Some-title-1"}

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 3, slug: "Some-title-2"}

      iex> IncrementalSlug.findItemWithGreatestIncrement(Post)
      %Post{id: 3, slug: "Some-title-2"}
  """
  @spec findItemWithGreatestIncrement(queryable :: Ecto.Queryable.t(), atom()) ::
          Ecto.Schema.t() | nil
  def findItemWithGreatestIncrement(queryable, to \\ @incremental_slug.to)

  def findItemWithGreatestIncrement(queryable, to),
      do: queryable |> order_by(desc: ^to) |> limit(1) |> @repo.one()

  @doc ~S"""
  Get a count of how many items have taken this exact slug.

  ## Parameters

  * `slug` - A regular slug without an increment.
  * `id` - Exclude this ID from the query.
  * `queryable` - In which table to look?
  * `to` - In which column is the slug stored?

  ## Examples

      iex> alias {Blog.Post, IncrementalSlug, Repo}

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
  def getCount(slug, id, queryable, to \\ @incremental_slug.to)

  def getCount(slug, id, queryable, to),
    do:
      queryable
      |> select(count("*"))
      |> limit(1)
      |> where([a], field(a, ^to) == ^slug)
      |> exlcudeID(id)
      |> @repo.one()

  @doc ~S"""
  Find the greatest increment from the items that have taken this slug.

  ## Parameters

  * `slug` - A regular slug without an increment.
  * `id` - Exclude this ID from the query.
  * `queryable` - In which table to look?
  * `to` - In which column is the slug stored?

  ## Return value

  The greatest increment or `0` if the slug is not taken.

  ## Useful to know

  `9` is the greatest increment that can be found. See why in `whereSlugWithIncrement/3`.

  ## Examples

      iex> alias {Blog.Post, IncrementalSlug, Repo}

      iex> IncrementalSlug.getGreatestIncrement("Some-title", nil, Post)
      0

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 1, title: "Some title", slug: "Some-title"}

      iex> IncrementalSlug.getGreatestIncrement("Some-title", nil, Post)
      0

      iex> Post.changeset(%Post{}, %{title: "Some title"}) |> Repo.insert!()
      %Post{id: 2, title: "Some title", slug: "Some-title-1"}

      iex> IncrementalSlug.getGreatestIncrement("Some-title", nil, Post)
      1
  """
  @spec getGreatestIncrement(
          slug :: String.t(),
          id :: integer(),
          queryable :: Ecto.Queryable.t(),
          to :: atom()
        ) :: integer()
  def getGreatestIncrement(slug, id, queryable, to \\ @incremental_slug.to)

  def getGreatestIncrement(slug, id, queryable, to),
    do: find(slug, id, queryable, to) |> getGreatestIncrement

  @doc ~S"""
  Extract an increment from the slug.

  ## Parameters

  * `slug` - A slug with an increment.

  ## Return value

  An increment or `0`.

  ## Examples

      iex> alias IncrementalSlug
      iex> IncrementalSlug.getGreatestIncrement(nil)
      0
      iex> IncrementalSlug.getGreatestIncrement("Some-title-1")
      1
      iex> IncrementalSlug.getGreatestIncrement("Some-title-5")
      5
  """
  @spec getGreatestIncrement(slug | nil :: String.t()) :: integer
  def getGreatestIncrement(slug) when is_nil(slug), do: 0

  def getGreatestIncrement(slug),
    do: slug |> String.split("-") |> List.last() |> String.to_integer()

  @doc ~S"""
  Find an increment that can make this slug unique.

  ## Parameters

  * `slug` - A regular slug without an increment.
  * `id` - Exclude this ID from the query.
  * `queryable` - In which table to look?
  * `to` - In which column is the slug stored?

  ## Return value

  The greatest increment `+1` or `1` if the slug is not taken.

  ## Useful to know

  `10` is the greatest available increment. See why in `whereSlugWithIncrement/3`.

  ## Examples

      iex> alias {Blog.Post, IncrementalSlug, Repo}

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
  def getIncrement(slug, id, queryable, to \\ @incremental_slug.to)

  def getIncrement(slug, id, queryable, to),
    do: getGreatestIncrement(slug, id, queryable, to) |> getIncrement

  # @doc false
  @spec getIncrement(lastIncrement :: integer()) :: integer()
  defp getIncrement(lastIncrement), do: lastIncrement + 1

  @doc ~S"""
  Get a slug from the passed string.

  Trim and pass it to [`Slugger.slugify/2`](https://github.com/h4cc/slugger)

  ## Examples

      iex> IncrementalSlug.getSlug("Some title")
      "Some-title"

      iex> IncrementalSlug.getSlug(" z e ā Č Ф А - Б В Г	Д š \ / * ^ % ! + ) |")
      "z-e-a-C-F-A-B-V-GD-s-or"
  """
  @spec getSlug(string :: nil) :: nil
  def getSlug(string) when is_nil(string), do: nil

  @spec getSlug(string :: String.t()) :: String.t()
  def getSlug(string), do: string |> String.trim() |> Slugger.slugify()

  @doc ~S"""
  Get a unique slug from the selected changeset's field.

  ## Parameter

  * `changeset` - Take the value from a field, and put back the slug in another.
  * `queryable` - In which table to look?
  * `from` - From which changeset's field generate the slug?
  * `to` - In which column is the slug stored?

  ## Examples

      iex> alias {Blog.Post, IncrementalSlug, Repo}

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
        from \\ @incremental_slug.from,
        to \\ @incremental_slug.to
      )

  def getSlugFromField(changeset, queryable, from, to),
    do: get_change(changeset, from) |> getUnique(get_change(changeset, :id), queryable, to)

  @doc ~S"""
  Get a unique slug from a string.

  ## Parameter

  * `string` - Generate the slug from this string.
  * `id` - Exclude this ID from the query.
  * `queryable` - In which table to look?
  * `to` - In which column is the slug stored?

  ## Return value

  A slug (with an increment, if it was taken).

  ## Examples

      iex> alias {Blog.Post, IncrementalSlug, Repo}

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
  def getUnique(string, id, queryable, to \\ @incremental_slug.to)

  def getUnique(string, id, queryable, _to) when is_nil(string) or id == 0 or is_nil(queryable),
    do: nil

  def getUnique(string, id, queryable, to),
    do: string |> getSlug |> makeSlugUnique(id, queryable, to)

  @doc ~S"""
  Check if another item has taken this slug.

  ## Parameters

  * `slug` - A regular slug without an increment.
  * `id` - Exclude this ID from the query.
  * `queryable` - In which table to look?
  * `to` - In which column is the slug stored?

  ## Examples

      iex> alias {Blog.Post, IncrementalSlug, Repo}

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
  def isTaken(slug, id, queryable, to \\ @incremental_slug.to)
  def isTaken(slug, id, queryable, _to) when is_nil(slug) or id == 0 or is_nil(queryable), do: nil
  def isTaken(slug, id, queryable, to), do: getCount(slug, id, queryable, to) > 0

  @doc ~S"""
  Append an increment (1-10), if this slug is already taken.

  ## Parameters

  * `slug` - A regular slug without an increment.
  * `id` - Exclude this ID from the query.
  * `queryable` - In which table to look?
  * `to` - In which column is the slug stored?

  ## Examples

      iex> alias {Blog.Post, IncrementalSlug, Repo}

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
  def makeSlugUnique(slug, id, queryable, to \\ @incremental_slug.to)

  def makeSlugUnique(slug, id, queryable, to),
    do: isTaken(slug, id, queryable, to) |> makeSlugUniqueIfTaken(slug, id, queryable, to)

  @doc ~S"""
  Append an increment (1-10), if this slug is already taken.

  ## Parameters

  * `taken` - is this slug already taken?
  * `slug` - A regular slug without an increment.
  * `id` - Exclude this ID from the query.
  * `queryable` - If it is taken, then get the last increment.
  * `to` - In which column is the slug stored?

  ## Examples

      iex> alias {Blog.Post, IncrementalSlug, Repo}

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
  def makeSlugUniqueIfTaken(taken, slug, id, queryable, to \\ @incremental_slug.to)

  def makeSlugUniqueIfTaken(taken, slug, id, queryable, to) when taken === true do
    increment = getIncrement(slug, id, queryable, to)
    slug |> append(increment)
  end

  def makeSlugUniqueIfTaken(_taken, slug, _id, _queryable, _to), do: slug

  @doc ~S"""
  Get a slug and put it in the changeset.

  ## Parameter

  * `changeset` - Take the value from a field, and put back the slug in another.
  * `queryable` - In which table to look?
  * `from` - From which changeset's field generate the slug?
  * `to` - In which column is the slug stored?

  ## Return values

  If everything went well, return the same changeset with a new slug, otherwise without.

  ## Examples

      iex> alias {Blog.Post, IncrementalSlug, Repo}

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
        from \\ @incremental_slug.from,
        to \\ @incremental_slug.to
      )

  def put(changeset, queryable, _from, _to) when is_nil(changeset) or is_nil(queryable),
    do: changeset

  def put(changeset, queryable, from, to),
    do: getSlugFromField(changeset, queryable, from, to) |> putSlug(changeset, to)

  @doc ~S"""
  Put this slug into the selected changeset's field.

  ## Parameters

  * `slug` - A regular slug without an increment.
  * `changeset` - Take the value from a field, and put back the slug in another.
  * `to` - In which column is the slug stored?

  ## Examples

      iex> alias {Blog.Post, IncrementalSlug, Repo}
      iex> changeset = Post.changeset(%Post{}, %{title: "Some title"})
      iex> changeset2 = "Some-slug" |> IncrementalSlug.putSlug(changeset)
      iex> changeset2.changes
      %{title: "Some title", uri: "Some-slug"},
  """
  @spec putSlug(slug :: String.t(), changeset :: Ecto.Changeset.t(), to :: atom()) ::
          Ecto.Changeset.t()
  def putSlug(slug, changeset, to \\ @incremental_slug.to),
    do: changeset |> put_change(to, slug)

  @doc ~S"""
  Specify the field where to look for a slug in a query.

  ## Parameters

  * `queryable` - In which table to look?
  * `to` - In which column is the slug stored?

  ## Return value

  A query with a selected field.

  ## Examples

      iex> alias {Blog.Post, IncrementalSlug}

      iex> IncrementalSlug.selectField(Post, :slug)
      #Ecto.Query<from p in Blog.Post, select: p.slug>

      iex> IncrementalSlug.selectField(Post, :uri)
      #Ecto.Query<from p in Blog.Post, select: p.uri>
  """
  @spec selectField(queryable :: Ecto.Queryable.t(), to :: atom()) :: Ecto.Query.t()
  def selectField(queryable, to \\ @incremental_slug.to)
  def selectField(queryable, to), do: queryable |> select([a], field(a, ^to))

  @doc ~S"""
  Search for slugs that start just like this one and end with '-' and exactly 1 character.

  * [MySQL pattern matching](https://dev.mysql.com/doc/refman/8.0/en/pattern-matching.htm)
  * [PostgreSQL pattern matching](https://www.postgresql.org/docs/8.3/functions-matching.html#FUNCTIONS-LIKE)

  ## Parameters

  * `queryable` - In which table to look?
  * `slug` - A regular slug without an increment.
  * `to` - In which column is the slug stored?

  ## Return value

  A query with a `WHERE LIKE` condition.

  ## Examples

      iex> alias {Blog.Post, IncrementalSlug}

      iex> IncrementalSlug.whereSlugWithIncrement(Post, "Some-title")
      #Ecto.Query<from p in Blog.Post, where: like(p.uri, ^"Some-title-_")>

      iex> IncrementalSlug.whereSlugWithIncrement(Post, "Hello-there")
      #Ecto.Query<from p in Blog.Post, where: like(p.uri, ^"Hello-there-_")>
  """
  @spec whereSlugWithIncrement(queryable :: Ecto.Queryable.t(), slug :: String.t(), atom()) ::
          Ecto.Query.t()
  def whereSlugWithIncrement(queryable, slug, to \\ @incremental_slug.to)

  def whereSlugWithIncrement(queryable, slug, to),
    do: queryable |> where([a], like(field(a, ^to), ^"#{slug}-_"))
end
