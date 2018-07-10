defmodule ElixirBackendWeb.Router do
  use ElixirBackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ElixirBackendWeb do
    pipe_through :api
  end
end
