defmodule BackendWeb.Blog.ArticleController do
  use BackendWeb, :controller

  alias Backend.Blog
  alias Backend.Blog.Article

  action_fallback BackendWeb.FallbackController

  def index(conn, _params) do
    blog_article = Blog.list_blog_article()
    render(conn, "index.json", blog_article: blog_article)
  end

  def create(conn, %{"article" => article_params}) do
    with {:ok, %Article{} = article} <- Blog.create_article(article_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", blog_article_path(conn, :show, article))
      |> render("show.json", article: article)
    end
  end

  def show(conn, %{"id" => id}) do
    article = Blog.get_article!(id)
    render(conn, "show.json", article: article)
  end

  def update(conn, %{"id" => id, "article" => article_params}) do
    article = Blog.get_article!(id)

    with {:ok, %Article{} = article} <- Blog.update_article(article, article_params) do
      render(conn, "show.json", article: article)
    end
  end

  def delete(conn, %{"id" => id}) do
    article = Blog.get_article!(id)
    with {:ok, %Article{}} <- Blog.delete_article(article) do
      send_resp(conn, :no_content, "")
    end
  end
end
