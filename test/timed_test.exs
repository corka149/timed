defmodule TimedTest do
  use ExUnit.Case
  doctest Timed

  ################### Start tests ###################
  test "set start with date and 'from' time provided" do
    args = [date: "2019-03-30", time: "07:50~", note: "Missing in ERP"]

    entry = %Timed{%Timed{}| args: args}
    %Timed{start: start_datetime, errors: errors} = Timed.set_start(entry)

    expected = ~N[2019-03-30 07:50:00]
    assert expected == start_datetime, List.to_string(errors)
  end

  test "set start with date and 'from~to' time provided" do
    args = [date: "2019-03-30", time: "07:50~17:00", note: "Missing in ERP"]

    entry = %Timed{%Timed{}| args: args}
    %Timed{start: start_datetime, errors: errors} = Timed.set_start(entry)

    expected = ~N[2019-03-30 07:50:00]
    assert expected == start_datetime, List.to_string(errors)
  end

  test "set start with date and 'to' time provided" do
    args = [date: "2019-03-30", time: "~17:00", note: "Missing in ERP"]

    entry = %Timed{%Timed{}| args: args}
    %Timed{start: start_datetime} = Timed.set_start(entry)

    expected = ~N[2019-03-30 07:50:00]
    assert start_datetime != nil, "Start date not set"
    assert expected.year == start_datetime.year
    assert expected.month == start_datetime.month
    assert expected.day == start_datetime.day
  end

  ################### End tests ###################
  test "set end with date and 'to' time provided" do
    args = [date: "2019-03-30", time: "~16:00", note: "Missing in ERP"]

    entry = %Timed{%Timed{}| args: args}
    %Timed{end: end_datetime, errors: errors} = Timed.set_end(entry)

    expected = ~N[2019-03-30 16:00:00]
    assert expected == end_datetime, List.to_string(errors)
  end

  test "set end with date and 'from~to' time provided" do
    args = [date: "2019-03-30", time: "07:50~17:00", note: "Missing in ERP"]

    entry = %Timed{%Timed{}| args: args}
    %Timed{end: end_datetime, errors: errors} = Timed.set_end(entry)

    expected = ~N[2019-03-30 17:00:00]
    assert expected == end_datetime, List.to_string(errors)
  end

  test "set end with date and 'from' time provided" do
    args = [date: "2019-03-30", time: "07:50~", note: "Missing in ERP"]

    entry = %Timed{%Timed{}| args: args}
    %Timed{end: end_datetime} = Timed.set_end(entry)

    expected = ~N[2019-03-30 07:50:00]
    assert end_datetime != nil, "Start date not set"
    assert expected.year == end_datetime.year
    assert expected.month == end_datetime.month
    assert expected.day == end_datetime.day
  end

  ################### note tests ###################
  test "set note" do
    expected = "Mising in ERP"
    args = [date: "2019-03-30", time: "07:50~", note: expected]
    entry = %Timed{%Timed{}| args: args}
    %Timed{note: actual} = Timed.set_note(entry)

    assert expected, actual
  end

  ################### break tests ###################
  test "set break when arg is available" do
    expected = 45
    args = [date: "2019-03-30", time: "07:50~", break: expected]
    entry = %Timed{%Timed{}| args: args}
    %Timed{break: actual} = Timed.set_break(entry)

    assert expected == actual
  end

  test "check default value when no break arg is available" do
    args = [date: "2019-03-30", time: "07:50~"]
    entry = %Timed{%Timed{}| args: args}
    %Timed{break: actual} = Timed.set_break(entry)

    assert 0 == actual
  end
end
