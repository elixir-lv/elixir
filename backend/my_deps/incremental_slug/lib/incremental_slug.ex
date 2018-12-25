defmodule IncrementalSlug do

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


  @doc ~S"""
  Append the increment to the slug.

      iex> "Some-title" |> Backend.IncrementalSlug.append(7)
      "Some-title-7"

      iex> "Hey" |> Backend.IncrementalSlug.append(123)
      "Hey-123"
  """
  @spec append(slug :: String.t(), increment :: integer) :: String.t()
  def append(slug, increment), do: "#{slug}-#{increment}"

end
