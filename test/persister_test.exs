defmodule TimedPersisterTest do
  use ExUnit.Case

  test "read db" do
    test_path = "test/assets/timed.csv"

    {should_fail, _} = Timed.Persister.read_db({:ok, "no/real/path/timed.csv"})
    assert :error == should_fail

    {:ok, splitted_rows} = Timed.Persister.read_db({:ok, test_path})
    assert 2 == length(splitted_rows)

    [row_1, row_2] = splitted_rows
    assert 5 == length(row_1)
    assert 5 == length(row_2)
  end

  test "convert line" do
    expected_entry = %Timed{%Timed{} | break: 45}
    expected_entry = %Timed{expected_entry | note: "Do it!"}
    expected_entry = %Timed{expected_entry | end: ~N[2018-01-19 17:00:00]}
    expected_entry = %Timed{expected_entry | start: ~N[2018-01-19 07:50:00]}

    test_line = ["2018-01-19", "07:50", "17:00", "45", "Do it!"]
    entry = Timed.Persister.convert_line(test_line)

    assert expected_entry == entry
  end

end
