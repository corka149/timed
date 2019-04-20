defmodule Timed do
  @moduledoc """

  """

  defstruct start: nil, end: nil, note: "", args: [], errors: []

  @doc """
  Sets the start of a Timed struct.
  """
  def set_start(%Timed{args: args, errors: errors} = entry) do
    date_time = Keyword.take(args, [:date, :time])
    [start_time, _] = parse_time(date_time)

    case calc_datetime(date_time, start_time) do
      {:ok, start}  -> %Timed{entry | start: start}
      {:error, _}   -> %Timed{entry | errors: errors ++ ["Invalid date/time format"]}
    end
  end

  @doc """
  Sets the end of a Timed struct.
  """
  def set_end(%Timed{args: args, errors: errors} = entry) do
    date_time = Keyword.take(args, [:date, :time])
    [_, end_time] = parse_time(date_time)

    case calc_datetime(date_time, end_time) do
      {:ok, start}  -> %Timed{entry | end: start}
      {:error, _}   -> %Timed{entry | errors: errors ++ ["Invalid date/time format"]}
    end
  end

  defp calc_datetime([date: date], "") do
    start_time = Time.utc_now()
    case Date.from_iso8601(date) do
      {:ok, start_date} -> NaiveDateTime.new(start_date, start_time)
      {result, reason}  -> {result, reason}
    end
  end

  defp calc_datetime([date: date, time: _], "") do
    start_time = Time.utc_now()
    case Date.from_iso8601(date) do
      {:ok, start_date} -> NaiveDateTime.new(start_date, start_time)
      {result, reason}  -> {result, reason}
    end
  end

  defp calc_datetime([date: date, time: _], start_time) do
    NaiveDateTime.from_iso8601("#{date} #{start_time}:00")
  end

  defp calc_datetime([time: _], start_time) do
    start_date = Date.utc_today()
    case Time.from_iso8601(start_time) do
      {:ok, start_time} -> NaiveDateTime.new(start_date, start_time)
      {result, reason}  -> {result, reason}
    end
  end

  defp calc_datetime(_, _) do
    {:error, "Unkown combination provided"}
  end

  defp parse_time(args) do
    time = Keyword.get(args, :time, "~")
    case String.split(time, "~") do
      dt when length(dt) == 2 -> dt
      _______________________ -> ["", ""]
    end
  end
end
