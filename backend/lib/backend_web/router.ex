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
	end
end
