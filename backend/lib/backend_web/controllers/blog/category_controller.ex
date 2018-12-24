defmodule BackendWeb.Blog.CategoryController do
  use BackendWeb, :controller

  alias Backend.Blog
  alias Backend.Blog.Category

  action_fallback BackendWeb.FallbackController

  def index(conn, _params) do
    blog_category = Blog.list_blog_category()
    render(conn, "index.json", blog_category: blog_category)
  end

  def create(conn, %{"category" => category_params}) do
    with {:ok, %Category{} = category} <- Blog.create_category(category_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", blog_category_path(conn, :show, category))
      |> render("show.json", category: category)
    end
  end

  def show(conn, %{"id" => id}) do
    category = Blog.get_category!(id)
    render(conn, "show.json", category: category)
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    category = Blog.get_category!(id)

    with {:ok, %Category{} = category} <- Blog.update_category(category, category_params) do
      render(conn, "show.json", category: category)
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Blog.get_category!(id)
    with {:ok, %Category{}} <- Blog.delete_category(category) do
      send_resp(conn, :no_content, "")
    end
  end
end
