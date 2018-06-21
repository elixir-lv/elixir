defmodule ElixirBackend.PostController do
  use ElixirBackend.Web, :controller
  alias ElixirBackend.Post

  def show(conn, _params) do
    query = from(a in Post, limit: 1)
    posts = ElixirBackend.Repo.one(query)
    render(conn, "show.json", post: posts)
  end
end
