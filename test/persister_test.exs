defmodule Timed.PersisterTest do
  use ExUnit.Case
  doctest Timed.Persister

  test "read db" do
    test_path = "test/assets/timed.csv"

    {should_fail, _} = Timed.Persister.read_db("no/real/path/timed.csv")
    assert :error == should_fail

    {:ok, splitted_rows} = Timed.Persister.read_db(test_path)
    assert 2 == length(splitted_rows)
  end

  test "convert line" do
    expected_entry = %Timed{%Timed{} | break: 45}
    expected_entry = %Timed{expected_entry | note: "Do it!"}
    expected_entry = %Timed{expected_entry | end: ~N[2018-01-19 17:00:00]}
    expected_entry = %Timed{expected_entry | start: ~N[2018-01-19 07:50:00]}

    test_line = ["2018-01-19", "07:50", "17:00", "45", "Do it!"]
    entry = Timed.Persister.convert_row(test_line)

    assert expected_entry == entry
  end

  test "convert content" do
    expected_entry1 = %Timed{%Timed{} | break: 45}
    expected_entry1 = %Timed{expected_entry1 | note: "Do it!"}
    expected_entry1 = %Timed{expected_entry1 | end: ~N[2018-01-19 17:00:00]}
    expected_entry1 = %Timed{expected_entry1 | start: ~N[2018-01-19 08:50:00]}

    expected_entry2 = %Timed{%Timed{} | break: 45}
    expected_entry2 = %Timed{expected_entry2 | note: "Yeah maybe"}
    expected_entry2 = %Timed{expected_entry2 | end: ~N[2018-01-20 16:00:00]}
    expected_entry2 = %Timed{expected_entry2 | start: ~N[2018-01-20 07:50:00]}

    content = """
    2018-01-19,08:50,17:00,45,Do it!
    2018-01-20,07:50,16:00,45,Yeah maybe
    """

    [first, second] = Timed.Persister.convert_content(content)

    assert first == expected_entry1 or first == expected_entry2
    assert second == expected_entry1 or second == expected_entry2
  end

  test "compare dates" do
    one_day = 60 * 60 * 24

    d1 = NaiveDateTime.utc_now()
    d2 = NaiveDateTime.add(d1, one_day, :second)

    t1 = %Timed{%Timed{} | start: d1}
    t2 = %Timed{%Timed{} | start: d2}
    t_nil = %Timed{}

    assert !Timed.Persister.compare_timed_dates(t_nil, t1), "Nil and struct are always different"
    assert !Timed.Persister.compare_timed_dates(t1, t_nil), "Nil and struct are always different"
    assert Timed.Persister.compare_timed_dates(t1, t1), "Used same struct, so must be same"
    assert !Timed.Persister.compare_timed_dates(t1, t2), "Different dates cannot be equal"
  end
end
