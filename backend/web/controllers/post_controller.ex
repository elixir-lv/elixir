defmodule ElixirBackend.PostController do
  use ElixirBackend.Web, :controller
  alias ElixirBackend.Post

  def index(conn, _params) do
    exit 'Welcome, at Posts!';

    query = from(
        a in "post",
        select: a.id, a.title
        limit: 1
      )

    posts = ElixirBackend.Repo.all(query)
  end
end
