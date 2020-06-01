defmodule Timed.CliTest do
  use ExUnit.Case
  doctest Timed.Cli

  test "parse args" do
    args = ["-b", "30", "-n", "Enter in ERP", "-d", "2019-03-21", "-s", "07:50", "-e", "17:00"]
    {parsed, _, _} = Timed.Cli.parse_args(args)

    assert [break: 30, note: "Enter in ERP", date: "2019-03-21", start: "07:50", end: "17:00"] == parsed
  end
end
