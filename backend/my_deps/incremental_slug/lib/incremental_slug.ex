defmodule IncrementalSlug do
  import Ecto.Query, warn: false
  import Ecto.Changeset

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
  # @repo Application.get_env(:incremental_slug, :repo)

  @doc ~S"""
  Append the increment to the slug.

      iex> "Slug-Doe" |> IncrementalSlug.append(7)
      "Slug-Doe-7"

      iex> "Henry" |> IncrementalSlug.append(123)
      "Henry-123"
  """
  @spec append(slug :: String.t(), increment :: integer) :: String.t()
  def append(slug, increment), do: "#{slug}-#{increment}"

  @doc ~S"""
  Exclude this ID from the query.

  ## Examples

      iex> import Ecto.Query, warn: false
      iex> query = TestPost |> select(count("*")) |> limit(1)
      #Ecto.Query<from t0 in IncrementalSlug.TestPost, limit: 1, select: count("*")>
      iex> IncrementalSlug.exclude_id(query, nil)
      #Ecto.Query<from t0 in IncrementalSlug.TestPost, limit: 1, select: count("*")>
      iex> IncrementalSlug.exclude_id(query, 123)
      #Ecto.Query<from t0 in IncrementalSlug.TestPost, where: t0.id != ^123, limit: 1, select: count("*")>
  """
  @spec exclude_id(queryable :: Ecto.Queryable.t(), id :: integer()) :: Ecto.Query.t()
  def exclude_id(queryable, id) when is_nil(id), do: queryable
  def exclude_id(queryable, id), do: queryable |> where([a], a.id != ^id)

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

      iex> TestPost.truncate
      iex> IncrementalSlug.find("Slug-Doe", nil, TestPost)
      nil
      iex> post = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"}) |> IncrementalSlug.repo().insert!()
      iex> post.slug == "Slug-Doe"
      true
      iex> IncrementalSlug.find("Slug-Doe", nil, TestPost)
      nil
      iex> post2 = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"}) |> IncrementalSlug.repo().insert!()
      iex> post2.slug == "Slug-Doe-1"
      true
      iex> IncrementalSlug.find("Slug-Doe", nil, TestPost)
      "Slug-Doe-1"
      iex> post3 = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"}) |> IncrementalSlug.repo().insert!()
      iex> post3.slug == "Slug-Doe-2"
      true
      iex> IncrementalSlug.find("Slug-Doe", nil, TestPost)
      "Slug-Doe-2"
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
      |> select_field(to)
      |> where_slug_with_increment(slug, to)
      |> exclude_id(id)
      |> find_item_with_greatest_increment(to)

  @doc ~S"""
  Find the item that has the slug with a greatest increment.

  ## Parameters

  * `queryable` - In which table to look?
  * `to` - In which column is the slug stored?

  ## Examples

      iex> TestPost.truncate
      iex> IncrementalSlug.find_item_with_greatest_increment(TestPost)
      nil
      iex> post = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"}) |> IncrementalSlug.repo().insert!()
      iex> post.slug == "Slug-Doe"
      true
      iex> post2 = IncrementalSlug.find_item_with_greatest_increment(TestPost)
      iex> post2.slug == "Slug-Doe"
      true
      iex> post3 = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"}) |> IncrementalSlug.repo().insert!()
      iex> post3.slug == "Slug-Doe-1"
      true
      iex> post4 = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"}) |> IncrementalSlug.repo().insert!()
      iex> post4.slug == "Slug-Doe-2"
      true
      iex> post5 = IncrementalSlug.find_item_with_greatest_increment(TestPost)
      iex> post5.slug == "Slug-Doe-2"
      true
  """
  @spec find_item_with_greatest_increment(queryable :: Ecto.Queryable.t(), atom()) ::
          Ecto.Schema.t() | nil
  def find_item_with_greatest_increment(queryable, to \\ @incremental_slug.to)

  def find_item_with_greatest_increment(queryable, to),
    do: queryable |> order_by(desc: ^to) |> limit(1) |> repo().one()

  @doc ~S"""
  Get a count of how many items have taken this exact slug.

  ## Parameters

  * `slug` - A regular slug without an increment.
  * `id` - Exclude this ID from the query.
  * `queryable` - In which table to look?
  * `to` - In which column is the slug stored?

  ## Examples

      iex> TestPost.truncate
      iex> IncrementalSlug.get_count("Slug-Doe", nil, TestPost)
      0
      iex> post = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"}) |> IncrementalSlug.repo().insert!()
      iex> post.slug == "Slug-Doe"
      true
      iex> IncrementalSlug.get_count("Slug-Doe", nil, TestPost)
      1
      iex> post1 = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"}) |> IncrementalSlug.repo().insert!()
      iex> post1.slug == "Slug-Doe-1"
      true
      iex> IncrementalSlug.get_count("Slug-Doe", nil, TestPost)
      1
  """
  @spec get_count(
          slug :: String.t(),
          id :: integer(),
          queryable :: Ecto.Queryable.t(),
          to :: atom()
        ) :: integer()
  def get_count(slug, id, queryable, to \\ @incremental_slug.to)

  def get_count(slug, id, queryable, to),
    do:
      queryable
      |> select(count("*"))
      |> limit(1)
      |> where([a], field(a, ^to) == ^slug)
      |> exclude_id(id)
      |> repo().one()

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

  `9` is the greatest increment that can be found. See why in `where_slug_with_increment/3`.

  ## Examples

      iex> TestPost.truncate
      iex> IncrementalSlug.get_greatest_increment("Slug-Doe", nil, TestPost)
      0
      iex> post = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"}) |> IncrementalSlug.repo().insert!()
      iex> post.slug == "Slug-Doe"
      true
      iex> IncrementalSlug.get_greatest_increment("Slug-Doe", nil, TestPost)
      0
      iex> post1 = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"}) |> IncrementalSlug.repo().insert!()
      iex> post1.slug == "Slug-Doe-1"
      true
      iex> IncrementalSlug.get_greatest_increment("Slug-Doe", nil, TestPost)
      1
  """
  @spec get_greatest_increment(
          slug :: String.t(),
          id :: integer(),
          queryable :: Ecto.Queryable.t(),
          to :: atom()
        ) :: integer()
  def get_greatest_increment(slug, id, queryable, to \\ @incremental_slug.to)

  def get_greatest_increment(slug, id, queryable, to),
    do: find(slug, id, queryable, to) |> get_greatest_increment()

  @doc ~S"""
  Extract an increment from the slug.

  ## Parameters

  * `slug` - A slug with an increment.

  ## Return value

  An increment or `0`.

  ## Examples

      iex> TestPost.truncate
      iex> IncrementalSlug.get_greatest_increment(nil)
      0
      iex> IncrementalSlug.get_greatest_increment("Slug-Doe-1")
      1
      iex> IncrementalSlug.get_greatest_increment("Slug-Doe-5")
      5
  """
  @spec get_greatest_increment(slug | nil :: String.t()) :: integer
  def get_greatest_increment(slug) when is_nil(slug), do: 0

  def get_greatest_increment(slug),
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

  `10` is the greatest available increment. See why in `where_slug_with_increment/3`.

  ## Examples

      iex> TestPost.truncate
      iex> IncrementalSlug.get_increment("Slug-Doe", nil, TestPost)
      1
      iex> post = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"}) |> IncrementalSlug.repo().insert!()
      iex> post.slug == "Slug-Doe"
      true
      iex> IncrementalSlug.get_increment("Slug-Doe", nil, TestPost)
      1
      iex> post1 = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"}) |> IncrementalSlug.repo().insert!()
      iex> post1.slug == "Slug-Doe-1"
      true
      iex> IncrementalSlug.get_increment("Slug-Doe", nil, TestPost)
      2
  """
  @spec get_increment(
          slug :: String.t(),
          id :: integer(),
          queryable :: Ecto.Queryable.t(),
          to :: atom()
        ) :: integer()
  def get_increment(slug, id, queryable, to \\ @incremental_slug.to)

  def get_increment(slug, id, queryable, to),
    do: slug |> get_greatest_increment(id, queryable, to) |> get_increment()

  # @doc false
  @spec get_increment(last_increment :: integer()) :: integer()
  defp get_increment(last_increment), do: last_increment + 1

  @doc ~S"""
  Get a slug from the passed string.

  Trim and pass it to [`Slugger.slugify/2`](https://github.com/h4cc/slugger)

  ## Examples

      iex> IncrementalSlug.get_slug("Slug Doe")
      "Slug-Doe"
      iex> IncrementalSlug.get_slug(" z e ā Č Ф А - Б В Г  Д š \ / * ^ % ! + ) |")
      "z-e-a-C-F-A-B-V-G-D-s-or"
  """
  @spec get_slug(string :: nil) :: nil
  def get_slug(string) when is_nil(string), do: nil

  @spec get_slug(string :: String.t()) :: String.t()
  def get_slug(string), do: string |> String.trim() |> Slugger.slugify()

  @doc ~S"""
  Get a unique slug from the selected changeset's field.

  ## Parameter

  * `changeset` - Take the value from a field, and put back the slug in another.
  * `queryable` - In which table to look?
  * `from` - From which changeset's field generate the slug?
  * `to` - In which column is the slug stored?

  ## Examples

      iex> TestPost.truncate
      iex> changeset = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"})
      iex> changeset |> IncrementalSlug.get_slug_from_field(TestPost)
      "Slug-Doe"
      iex> post = changeset |> IncrementalSlug.repo().insert!()
      iex> post.slug == "Slug-Doe"
      true
      iex> changeset |> IncrementalSlug.get_slug_from_field(TestPost)
      "Slug-Doe-1"
  """
  @spec get_slug_from_field(
          changeset :: Ecto.Changeset.t(),
          queryable :: Ecto.Queryable.t(),
          from :: atom(),
          to :: atom()
        ) :: String.t()
  def get_slug_from_field(
        changeset,
        queryable,
        from \\ @incremental_slug.from,
        to \\ @incremental_slug.to
      )

  def get_slug_from_field(changeset, queryable, from, to) do
    string = changeset |> get_change(from)
    id = changeset |> get_change(:id)

    string |> get_unique(id, queryable, to)
  end

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

      iex> TestPost.truncate
      iex> IncrementalSlug.get_unique("Slug Doe", nil, TestPost)
      "Slug-Doe"
      iex> post = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"}) |> IncrementalSlug.repo().insert!()
      iex> post.slug == "Slug-Doe"
      true
      iex> IncrementalSlug.get_unique("Slug Doe", nil, TestPost)
      "Slug-Doe-1"
  """
  @spec get_unique(
          string :: String.t(),
          id :: integer(),
          queryable :: Ecto.Queryable.t(),
          to :: atom()
        ) :: String.t()
  def get_unique(string, id, queryable, to \\ @incremental_slug.to)

  def get_unique(string, id, queryable, _to) when is_nil(string) or id == 0 or is_nil(queryable),
    do: nil

  def get_unique(string, id, queryable, to),
    do: string |> get_slug |> make_slug_unique(id, queryable, to)

  @doc ~S"""
  Check if another item has taken this slug.

  ## Parameters

  * `slug` - A regular slug without an increment.
  * `id` - Exclude this ID from the query.
  * `queryable` - In which table to look?
  * `to` - In which column is the slug stored?

  ## Examples

      iex> TestPost.truncate
      iex> IncrementalSlug.is_taken("Slug-Doe", nil, TestPost)
      false
      iex> post = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"}) |> IncrementalSlug.repo().insert!()
      iex> post.slug == "Slug-Doe"
      true
      iex> IncrementalSlug.is_taken("Slug-Doe", nil, TestPost)
      true
  """
  @spec is_taken(
          slug :: String.t(),
          id :: integer(),
          queryable :: Ecto.Queryable.t(),
          to :: atom()
        ) :: boolean()
  def is_taken(slug, id, queryable, to \\ @incremental_slug.to)

  def is_taken(slug, id, queryable, _to) when is_nil(slug) or id == 0 or is_nil(queryable),
    do: nil

  def is_taken(slug, id, queryable, to), do: slug |> get_count(id, queryable, to) > 0

  @doc ~S"""
  Append an increment (1-10), if this slug is already taken.

  ## Parameters

  * `slug` - A regular slug without an increment.
  * `id` - Exclude this ID from the query.
  * `queryable` - In which table to look?
  * `to` - In which column is the slug stored?

  ## Examples

      iex> TestPost.truncate
      iex> IncrementalSlug.make_slug_unique("Slug-Doe", nil, TestPost)
      "Slug-Doe"
      iex> post = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"}) |> IncrementalSlug.repo().insert!()
      iex> post.slug == "Slug-Doe"
      true
      iex> IncrementalSlug.make_slug_unique("Slug-Doe", nil, TestPost)
      "Slug-Doe-1"
  """
  @spec make_slug_unique(
          slug :: String.t(),
          id :: integer(),
          queryable :: Ecto.Queryable.t(),
          to :: atom()
        ) :: String.t()
  def make_slug_unique(slug, id, queryable, to \\ @incremental_slug.to)

  def make_slug_unique(slug, id, queryable, to),
    do: slug |> is_taken(id, queryable, to) |> make_slug_unique_if_taken(slug, id, queryable, to)

  @doc ~S"""
  Append an increment (1-10), if this slug is already taken.

  ## Parameters

  * `taken` - is this slug already taken?
  * `slug` - A regular slug without an increment.
  * `id` - Exclude this ID from the query.
  * `queryable` - If it is taken, then get the last increment.
  * `to` - In which column is the slug stored?

  ## Examples

      iex> TestPost.truncate
      iex> IncrementalSlug.make_slug_unique_if_taken(false, "Slug-Doe", nil, TestPost)
      "Slug-Doe"
      iex> post = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"}) |> IncrementalSlug.repo().insert!()
      iex> post.slug == "Slug-Doe"
      true
      iex>  IncrementalSlug.make_slug_unique_if_taken(false, "Slug-Doe", nil, TestPost)
      "Slug-Doe"
      iex>  IncrementalSlug.make_slug_unique_if_taken(true, "Slug-Doe", nil, TestPost)
      "Slug-Doe-1"
      iex> post1 = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"}) |> IncrementalSlug.repo().insert!()
      iex> post1.slug == "Slug-Doe-1"
      true
      iex>  IncrementalSlug.make_slug_unique_if_taken(true, "Slug-Doe", nil, TestPost)
      "Slug-Doe-2"
  """
  @spec make_slug_unique_if_taken(
          taken :: boolean(),
          slug :: String.t(),
          id :: integer(),
          queryable :: Ecto.Queryable.t(),
          to :: atom()
        ) :: String.t()
  def make_slug_unique_if_taken(taken, slug, id, queryable, to \\ @incremental_slug.to)

  def make_slug_unique_if_taken(taken, slug, id, queryable, to) when taken === true do
    increment = slug |> get_increment(id, queryable, to)
    slug |> append(increment)
  end

  def make_slug_unique_if_taken(_taken, slug, _id, _queryable, _to), do: slug

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

      iex> TestPost.truncate
      iex> changeset = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"}) |> IncrementalSlug.put(TestPost)
      iex> post = changeset |> IncrementalSlug.repo().insert!()
      iex> post.slug == "Slug-Doe"
      true
      iex> changeset2 = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"}) |> IncrementalSlug.put(TestPost)
      iex> post1 = changeset2 |> IncrementalSlug.repo().insert!()
      iex> post1.slug == "Slug-Doe-1"
      true
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
    do: changeset |> get_slug_from_field(queryable, from, to) |> put_slug(changeset, to)

  @doc ~S"""
  Put this slug into the selected changeset's field.

  ## Parameters

  * `slug` - A regular slug without an increment.
  * `changeset` - Take the value from a field, and put back the slug in another.
  * `to` - In which column is the slug stored?

  ## Examples

      iex> TestPost.truncate
      iex> changeset = TestPost.changeset(%TestPost{}, %{title: "Slug Doe"})
      iex> changeset2 = "Slug-Doe" |> IncrementalSlug.put_slug(changeset)
      iex> changeset2.changes
      %{title: "Slug Doe", slug: "Slug-Doe"}
  """
  @spec put_slug(slug :: String.t(), changeset :: Ecto.Changeset.t(), to :: atom()) ::
          Ecto.Changeset.t()
  def put_slug(slug, changeset, to \\ @incremental_slug.to),
    do: changeset |> put_change(to, slug)

  @doc ~S"""
  Connect to the project's repository.

  Required to collect data from the table like using `IncrementalSlug.repo().one()`.
  """
  def repo() do
    Application.get_env(:incremental_slug, :repo)
  end

  @doc ~S"""
  Specify the field where to look for a slug in a query.

  ## Parameters

  * `queryable` - In which table to look?
  * `to` - In which column is the slug stored?

  ## Return value

  A query with a selected field.

  ## Examples

      iex> TestPost.truncate
      iex> IncrementalSlug.select_field(TestPost, :slug)
      #Ecto.Query<from t0 in IncrementalSlug.TestPost, select: t0.slug>
      iex> IncrementalSlug.select_field(TestPost, :slug)
      #Ecto.Query<from t0 in IncrementalSlug.TestPost, select: t0.slug>
  """
  @spec select_field(queryable :: Ecto.Queryable.t(), to :: atom()) :: Ecto.Query.t()
  def select_field(queryable, to \\ @incremental_slug.to)
  def select_field(queryable, to), do: queryable |> select([a], field(a, ^to))

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

      iex> TestPost.truncate
      iex> IncrementalSlug.where_slug_with_increment(TestPost, "Slug-Doe")
      #Ecto.Query<from t0 in IncrementalSlug.TestPost, where: like(t0.slug, ^"Slug-Doe-_")>
      iex> IncrementalSlug.where_slug_with_increment(TestPost, "Henry")
      #Ecto.Query<from t0 in IncrementalSlug.TestPost, where: like(t0.slug, ^"Henry-_")>
  """
  @spec where_slug_with_increment(queryable :: Ecto.Queryable.t(), slug :: String.t(), atom()) ::
          Ecto.Query.t()
  def where_slug_with_increment(queryable, slug, to \\ @incremental_slug.to)

  def where_slug_with_increment(queryable, slug, to),
    do: queryable |> where([a], like(field(a, ^to), ^"#{slug}-_"))
end
