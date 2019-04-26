defmodule TimedTest do
  use ExUnit.Case
  doctest Timed

  ################### Start tests ###################
  test "set start with date and 'from' time provided" do
    args = [date: "2019-03-30", time: "07:50~", note: "Missing in ERP"]

    entry = %Timed{}
    %Timed{start: start_datetime, errors: errors} = Timed.set_start(entry, args)

    expected = ~N[2019-03-30 07:50:00]
    assert expected == start_datetime, List.to_string(errors)
  end

  test "set start with date and 'from~to' time provided" do
    args = [date: "2019-03-30", time: "07:50~17:00", note: "Missing in ERP"]

    entry = %Timed{}
    %Timed{start: start_datetime, errors: errors} = Timed.set_start(entry, args)

    expected = ~N[2019-03-30 07:50:00]
    assert expected == start_datetime, List.to_string(errors)
  end

  test "set start with date and 'to' time provided" do
    args = [date: "2019-03-30", time: "~17:00", note: "Missing in ERP"]

    entry = %Timed{}
    %Timed{start: start_datetime} = Timed.set_start(entry, args)

    expected = ~N[2019-03-30 07:50:00]
    assert start_datetime != nil, "Start date not set"
    assert expected.year == start_datetime.year
    assert expected.month == start_datetime.month
    assert expected.day == start_datetime.day
  end

  ################### End tests ###################
  test "set end with date and 'to' time provided" do
    args = [date: "2019-03-30", time: "~16:00", note: "Missing in ERP"]

    entry = %Timed{}
    %Timed{end: end_datetime, errors: errors} = Timed.set_end(entry, args)

    expected = ~N[2019-03-30 16:00:00]
    assert expected == end_datetime, List.to_string(errors)
  end

  test "set end with date and 'from~to' time provided" do
    args = [date: "2019-03-30", time: "07:50~17:00", note: "Missing in ERP"]

    entry = %Timed{}
    %Timed{end: end_datetime, errors: errors} = Timed.set_end(entry, args)

    expected = ~N[2019-03-30 17:00:00]
    assert expected == end_datetime, List.to_string(errors)
  end

  test "set end with date and 'from' time provided" do
    args = [date: "2019-03-30", time: "07:50~", note: "Missing in ERP"]

    entry = %Timed{}
    %Timed{end: end_datetime} = Timed.set_end(entry, args)

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
    entry = %Timed{}
    %Timed{note: actual} = Timed.set_note(entry, args)

    assert expected, actual
  end

  ################### break tests ###################
  test "set break when arg is available" do
    expected = 45
    args = [date: "2019-03-30", time: "07:50~", break: expected]
    entry = %Timed{}
    %Timed{break: actual} = Timed.set_break(entry, args)

    assert expected == actual
  end

  test "check default value when no break arg is available" do
    args = [date: "2019-03-30", time: "07:50~"]
    entry = %Timed{}
    %Timed{break: actual} = Timed.set_break(entry, args)

    assert 0 == actual
  end

  ################### calc date and time tests ###################
  test "calc date and time from args - date set" do
    args = [date: "2018-12-01"]
    now = Time.utc_now()
    {:ok, datetime} = Timed.calc_datetime(args, "")
    assert ~D(2018-12-01) == NaiveDateTime.to_date(datetime)
    assert now.hour == datetime.hour
  end

  test "calc date and time from args - time set" do
    args = [time: "07:50~"]
    today = Date.utc_today()
    {:ok, datetime} = Timed.calc_datetime(args, "07:50")
    assert today == NaiveDateTime.to_date(datetime)
    assert ~T(07:50:00) == NaiveDateTime.to_time(datetime)
  end

  test "calc date and time from args - date and time set" do
    args = [date: "2018-11-11", time: "07:50~"]
    {:ok, datetime} = Timed.calc_datetime(args, "07:50")
    assert ~D(2018-11-11) == NaiveDateTime.to_date(datetime)
    assert ~T(07:50:00) == NaiveDateTime.to_time(datetime)
  end

  test "calc date und time - wrong combination" do
    assert {:error, "Unkown combination provided"} == Timed.calc_datetime([], "07:50")
  end
end
