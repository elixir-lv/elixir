defmodule Backend.BlogTest do
  use Backend.DataCase

  alias Backend.Blog

  describe "posts" do
    alias Backend.Blog.Post

    @valid_attrs %{title: "Some title"}
    @update_attrs %{title: "some updated title"}
    @invalid_attrs %{title: nil}

    def post_fixture(attrs \\ %{}) do
      {:ok, post} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Blog.create_post()

      post
    end

    #test "list_posts/0 returns all posts" do
     # post = post_fixture()
      #assert Blog.list_posts() == [post]
    #end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Blog.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      assert {:ok, %Post{} = post} = Blog.create_post(@valid_attrs)
      assert post.title == "Some title"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      assert {:ok, post} = Blog.update_post(post, @update_attrs)
      assert %Post{} = post
      assert post.title == "some updated title"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_post(post, @invalid_attrs)
      assert post == Blog.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Blog.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Blog.change_post(post)
    end

		test "getUriFromString/1 test URI" do
			assert is_nil(IncrementalSlug.getSlug(nil))
			assert "z-e-a-C-F-A-B-V-G-D-s-or" = IncrementalSlug.getSlug("z e ā Č Ф А - Б В Г	Д š \ / * ^ % ! + ) |")
    end

    test "Increment URI" do

      uri = "Some-title";
      assert false == IncrementalSlug.isTaken(uri, nil, Post)
      assert {:ok, %Post{} = post} = Blog.create_post(@valid_attrs)
      assert post.uri == uri
      assert false == IncrementalSlug.isTaken(uri, post.id, Post)
      assert true == IncrementalSlug.isTaken(uri, 999, Post)
      assert true == IncrementalSlug.isTaken(uri, nil, Post)

      uri = "Some-title-1";
      assert false == IncrementalSlug.isTaken(uri, nil, Post)
      assert {:ok, %Post{} = post2} = Blog.create_post(@valid_attrs)
      assert post2.uri == uri
      assert post2.title == post.title
      assert post2.id != post.id
      assert post2.uri != post.uri
      assert false == IncrementalSlug.isTaken(uri, post2.id, Post)
      assert true == IncrementalSlug.isTaken(uri, 999, Post)
      assert true == IncrementalSlug.isTaken(uri, nil, Post)

      uri = "Some-title-2";
      assert false == IncrementalSlug.isTaken(uri, nil, Post)
      assert {:ok, %Post{} = post3} = Blog.create_post(@valid_attrs)
      assert post2.id != post3.id
      assert post3.uri == uri
      assert false == IncrementalSlug.isTaken(uri, post3.id, Post)
      assert true == IncrementalSlug.isTaken(uri, 999, Post)
      assert true == IncrementalSlug.isTaken(uri, nil, Post)

      uri = "Some-title-1-1";
      assert false == IncrementalSlug.isTaken(uri, nil, Post)
      assert {:ok, %Post{} = post} = Blog.create_post(%{title: "Some title 1"})
      assert post.uri == uri
      assert false == IncrementalSlug.isTaken(uri, post.id, Post)
      assert true == IncrementalSlug.isTaken(uri, 999, Post)
      assert true == IncrementalSlug.isTaken(uri, nil, Post)

      uri = "Some-title-1-2";
      assert false == IncrementalSlug.isTaken(uri, nil, Post)
      assert {:ok, %Post{} = post} = Blog.create_post(%{title: "Some title 1"})
      assert post.uri == uri
      assert false == IncrementalSlug.isTaken(uri, post.id, Post)
      assert true == IncrementalSlug.isTaken(uri, 999, Post)
      assert true == IncrementalSlug.isTaken(uri, nil, Post)

      uri = "Some-title-2-1";
      assert false == IncrementalSlug.isTaken(uri, nil, Post)
      assert {:ok, %Post{} = post} = Blog.create_post(%{title: "Some title 2"})
      assert post.uri == uri
      assert false == IncrementalSlug.isTaken(uri, post.id, Post)
      assert true == IncrementalSlug.isTaken(uri, 999, Post)
      assert true == IncrementalSlug.isTaken(uri, nil, Post)

      uri = "Some-title-2-2";
      assert false == IncrementalSlug.isTaken(uri, nil, Post)
      assert {:ok, %Post{} = post} = Blog.create_post(%{title: "Some title 2"})
      assert post.uri == uri
      assert false == IncrementalSlug.isTaken(uri, post.id, Post)
      assert true == IncrementalSlug.isTaken(uri, 999, Post)
      assert true == IncrementalSlug.isTaken(uri, nil, Post)

      uri = "Some-title-7";
      assert false == IncrementalSlug.isTaken(uri, nil, Post)
      assert {:ok, %Post{} = post} = Blog.create_post(%{title: "Some title 7"})
      assert post.uri == uri
      assert false == IncrementalSlug.isTaken(uri, post.id, Post)
      assert true == IncrementalSlug.isTaken(uri, 999, Post)
      assert true == IncrementalSlug.isTaken(uri, nil, Post)

      uri = "Some-title-7-1";
      assert false == IncrementalSlug.isTaken(uri, nil, Post)
      assert {:ok, %Post{} = post} = Blog.create_post(%{title: "Some title 7"})
      assert post.uri == uri
      assert false == IncrementalSlug.isTaken(uri, post.id, Post)
      assert true == IncrementalSlug.isTaken(uri, 999, Post)
      assert true == IncrementalSlug.isTaken(uri, nil, Post)
    end
  end

  describe "blog_article" do
    alias Backend.Blog.Article

    @update_attrs %{title: "some updated title"}
    @invalid_attrs %{title: nil}

    def article_fixture(attrs \\ %{}) do
      {:ok, article} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Blog.create_article()

      article
    end

    test "list_blog_article/0 returns all blog_article" do
      article = article_fixture()
      assert Blog.list_blog_article() == [article]
    end

    test "get_article!/1 returns the article with given id" do
      article = article_fixture()
      assert Blog.get_article!(article.id) == article
    end

    test "create_article/1 with valid data creates a article" do
      assert {:ok, %Article{} = article} = Blog.create_article(@valid_attrs)
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_article(@invalid_attrs)
    end

    test "update_article/2 with valid data updates the article" do
      article = article_fixture()
      assert {:ok, article} = Blog.update_article(article, @update_attrs)
      assert %Article{} = article
    end

    test "update_article/2 with invalid data returns error changeset" do
      article = article_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_article(article, @invalid_attrs)
      assert article == Blog.get_article!(article.id)
    end

    test "delete_article/1 deletes the article" do
      article = article_fixture()
      assert {:ok, %Article{}} = Blog.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_article!(article.id) end
    end

    test "change_article/1 returns a article changeset" do
      article = article_fixture()
      assert %Ecto.Changeset{} = Blog.change_article(article)
    end
  end

  describe "blog_category" do
    alias Backend.Blog.Category

    @valid_attrs %{title: "some title"}
    @update_attrs %{title: "some updated title"}
    @invalid_attrs %{title: nil}

    def category_fixture(attrs \\ %{}) do
      {:ok, category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Blog.create_category()

      category
    end

    test "list_blog_category/0 returns all blog_category" do
      category = category_fixture()
      assert Blog.list_blog_category() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Blog.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      assert {:ok, %Category{} = category} = Blog.create_category(@valid_attrs)
      assert category.title == "some title"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      assert {:ok, category} = Blog.update_category(category, @update_attrs)
      assert %Category{} = category
      assert category.title == "some updated title"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_category(category, @invalid_attrs)
      assert category == Blog.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Blog.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Blog.change_category(category)
    end
  end
end
