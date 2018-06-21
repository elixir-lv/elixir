defmodule ElixirTestProjectTest do
  use ExUnit.Case
  doctest ElixirTestProject

  test "greets the world" do
    assert ElixirTestProject.hello() == :world
  end
end
