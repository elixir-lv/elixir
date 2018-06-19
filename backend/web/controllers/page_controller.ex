defmodule ElixirBackend.PageController do
  use ElixirBackend.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
