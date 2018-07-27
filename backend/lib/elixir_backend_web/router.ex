defmodule ElixirBackendWeb.Router do
  use ElixirBackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ElixirBackendWeb do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit]
    resources "/posts", PostController, except: [:new, :edit]
  end
end
