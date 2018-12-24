defmodule BackendWeb.Blog.ArticleControllerTest do
  use BackendWeb.ConnCase

  alias Backend.Blog
  alias Backend.Blog.Article

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  def fixture(:article) do
    {:ok, article} = Blog.create_article(@create_attrs)
    article
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all blog_article", %{conn: conn} do
      conn = get conn, blog_article_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create article" do
    test "renders article when data is valid", %{conn: conn} do
      conn = post conn, blog_article_path(conn, :create), article: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, blog_article_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, blog_article_path(conn, :create), article: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update article" do
    setup [:create_article]

    test "renders article when data is valid", %{conn: conn, article: %Article{id: id} = article} do
      conn = put conn, blog_article_path(conn, :update, article), article: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, blog_article_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id}
    end

    test "renders errors when data is invalid", %{conn: conn, article: article} do
      conn = put conn, blog_article_path(conn, :update, article), article: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete article" do
    setup [:create_article]

    test "deletes chosen article", %{conn: conn, article: article} do
      conn = delete conn, blog_article_path(conn, :delete, article)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, blog_article_path(conn, :show, article)
      end
    end
  end

  defp create_article(_) do
    article = fixture(:article)
    {:ok, article: article}
  end
end
