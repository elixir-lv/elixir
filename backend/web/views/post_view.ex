defmodule ElixirBackend.PostView do
    use ElixirBackend.Web, :view

    def render("show.json", %{post: post}) do
      %{id: post.id, title: post.title}
    end

    def render("index.json", %{posts: posts}) do
      %{data: posts}
    end
  end
