defmodule ElixirBackend.Router do
  use ElixirBackend.Web, :router
  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ElixirBackend do
    pipe_through :api

    get "/", PageController, :index
    get "/posts", PostController, :index
  end
end
