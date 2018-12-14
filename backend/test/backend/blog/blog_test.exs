defmodule Backend.BlogTest do
  use Backend.DataCase

  alias Backend.Blog
  alias Backend.IncrementalSlug

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
			assert is_nil(IncrementalSlug.getUriFromString(nil))
			assert "z-e-a-C-F-A-B-V-G-D-s-or" = IncrementalSlug.getUriFromString("z e ā Č Ф А - Б В Г	Д š \ / * ^ % ! + ) |")
    end

    test "Increment URI" do

      uri = "Some-title";
      assert false == IncrementalSlug.isURItaken(uri, nil, Post)
      assert {:ok, %Post{} = post} = Blog.create_post(@valid_attrs)
      assert post.uri == uri
      assert false == IncrementalSlug.isURItaken(uri, post.id, Post)
      assert true == IncrementalSlug.isURItaken(uri, 999, Post)
      assert true == IncrementalSlug.isURItaken(uri, nil, Post)

      uri = "Some-title-1";
      assert false == IncrementalSlug.isURItaken(uri, nil, Post)
      assert {:ok, %Post{} = post2} = Blog.create_post(@valid_attrs)
      assert post2.uri == uri
      assert post2.title == post.title
      assert post2.id != post.id
      assert post2.uri != post.uri
      assert false == IncrementalSlug.isURItaken(uri, post2.id, Post)
      assert true == IncrementalSlug.isURItaken(uri, 999, Post)
      assert true == IncrementalSlug.isURItaken(uri, nil, Post)

      uri = "Some-title-2";
      assert false == IncrementalSlug.isURItaken(uri, nil, Post)
      assert {:ok, %Post{} = post3} = Blog.create_post(@valid_attrs)
      assert post2.id != post3.id
      assert post3.uri == uri
      assert false == IncrementalSlug.isURItaken(uri, post3.id, Post)
      assert true == IncrementalSlug.isURItaken(uri, 999, Post)
      assert true == IncrementalSlug.isURItaken(uri, nil, Post)

      uri = uri = "Some-title-1-1";
      assert false == IncrementalSlug.isURItaken(uri, nil, Post)
      assert {:ok, %Post{} = post} = Blog.create_post(%{title: "Some title 1"})
      assert post.uri == uri
      assert false == IncrementalSlug.isURItaken(uri, post.id, Post)
      assert true == IncrementalSlug.isURItaken(uri, 999, Post)
      assert true == IncrementalSlug.isURItaken(uri, nil, Post)

      uri = uri = "Some-title-1-2";
      assert false == IncrementalSlug.isURItaken(uri, nil, Post)
      assert {:ok, %Post{} = post} = Blog.create_post(%{title: "Some title 1"})
      assert post.uri == uri
      assert false == IncrementalSlug.isURItaken(uri, post.id, Post)
      assert true == IncrementalSlug.isURItaken(uri, 999, Post)
      assert true == IncrementalSlug.isURItaken(uri, nil, Post)

      uri = uri = "Some-title-2-1";
      assert false == IncrementalSlug.isURItaken(uri, nil, Post)
      assert {:ok, %Post{} = post} = Blog.create_post(%{title: "Some title 2"})
      assert post.uri == uri
      assert false == IncrementalSlug.isURItaken(uri, post.id, Post)
      assert true == IncrementalSlug.isURItaken(uri, 999, Post)
      assert true == IncrementalSlug.isURItaken(uri, nil, Post)

      uri = uri = "Some-title-2-2";
      assert false == IncrementalSlug.isURItaken(uri, nil, Post)
      assert {:ok, %Post{} = post} = Blog.create_post(%{title: "Some title 2"})
      assert post.uri == uri
      assert false == IncrementalSlug.isURItaken(uri, post.id, Post)
      assert true == IncrementalSlug.isURItaken(uri, 999, Post)
      assert true == IncrementalSlug.isURItaken(uri, nil, Post)

      uri = uri = "Some-title-7";
      assert false == IncrementalSlug.isURItaken(uri, nil, Post)
      assert {:ok, %Post{} = post} = Blog.create_post(%{title: "Some title 7"})
      assert post.uri == uri
      assert false == IncrementalSlug.isURItaken(uri, post.id, Post)
      assert true == IncrementalSlug.isURItaken(uri, 999, Post)
      assert true == IncrementalSlug.isURItaken(uri, nil, Post)

      uri = uri = "Some-title-7-1";
      assert false == IncrementalSlug.isURItaken(uri, nil, Post)
      assert {:ok, %Post{} = post} = Blog.create_post(%{title: "Some title 7"})
      assert post.uri == uri
      assert false == IncrementalSlug.isURItaken(uri, post.id, Post)
      assert true == IncrementalSlug.isURItaken(uri, 999, Post)
      assert true == IncrementalSlug.isURItaken(uri, nil, Post)
    end
  end
end
