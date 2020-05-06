defmodule CommunicatorTest do
  use ExUnit.Case
  doctest Communicator

  test "greets the world" do
    assert Communicator.hello() == :world
  end
end
