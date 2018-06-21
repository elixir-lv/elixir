defmodule ElixirBackend.PostController do
  use ElixirBackend.Web, :controller

  def index(conn, _params) do
    exit 'Welcome, at Posts!';
  end
end
