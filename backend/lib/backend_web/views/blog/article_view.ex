defmodule BackendWeb.Blog.ArticleView do
  use BackendWeb, :view
  alias BackendWeb.Blog.ArticleView

  def render("index.json", %{blog_article: blog_article}) do
    %{data: render_many(blog_article, ArticleView, "article.json")}
  end

  def render("show.json", %{article: article}) do
    %{data: render_one(article, ArticleView, "article.json")}
  end

  def render("article.json", %{article: article}) do
    %{id: article.id}
  end
end
