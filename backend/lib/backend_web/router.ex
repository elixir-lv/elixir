defmodule BackendWeb.Router do
  use BackendWeb, :router

  pipeline :api do
		plug CORSPlug, origin: ["http://elixir.local"]
    plug :accepts, ["json"]
  end

	scope "/api", BackendWeb do
			pipe_through :api
			resources "/users", UserController
      resources "/posts", PostController

      scope "/blog", Blog do
        resources "/article", ArticleController, as: :blog_article
        resources "/category", CategoryController, as: :blog_category
      end
  end


end
