defmodule ElixirBackend.PostController do
  use ElixirBackend.Web, :controller
  alias ElixirBackend.Post

  def show(conn, _params) do
    post = Post.get_first()
    render(conn, "show.json", post: post)
  end
end
