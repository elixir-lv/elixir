defmodule BackendWeb.Blog.CategoryView do
  use BackendWeb, :view
  alias BackendWeb.Blog.CategoryView

  def render("index.json", %{blog_category: blog_category}) do
    %{data: render_many(blog_category, CategoryView, "category.json")}
  end

  def render("show.json", %{category: category}) do
    %{data: render_one(category, CategoryView, "category.json")}
  end

  def render("category.json", %{category: category}) do
    %{id: category.id,
      title: category.title}
  end
end
