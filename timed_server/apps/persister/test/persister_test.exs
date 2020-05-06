defmodule PersisterTest do
  use ExUnit.Case
  doctest Persister

  test "greets the world" do
    assert Persister.hello() == :world
  end
end
