defmodule CliTest do
  use ExUnit.Case
  doctest Timed

  test "parse args" do
    args = ["-b", "30", "-n", "Enter in ERP", "-d", "2019-03-21", "-t", "07:50~17:00", "-i"]
    {parsed, _, _} = Timed.Cli.parse_args(args)

    assert [break: 30, note: "Enter in ERP", date: "2019-03-21", time: "07:50~17:00", interactive: true] == parsed
  end

end
