defmodule Timed do
  @moduledoc """
  Bundles functions around transforming working times.
  """

  defstruct start: nil, end: nil, note: "", break: 0, args: [], errors: []

  @doc """
  Sets the break in minutes provided via args
  """
  def set_break(%Timed{args: args} = entry) do
    case Keyword.take(args, [:break]) do
       [note: minutes]  -> %Timed{entry | break: minutes}
        _               -> entry
    end
  end

  @doc """
  Set the note given through the args
  """
  def set_note(%Timed{args: args} = entry) do
    case Keyword.take(args, [:note]) do
       [note: text] -> %Timed{entry | note: text}
        _           -> entry
    end
  end

  @doc """
  Sets the start time and date.
  """
  def set_start(entry) do
    set_time(entry, :start)
  end

  @doc """
  Sets the end time and date.
  """
  def set_end(entry) do
    set_time(entry, :end)
  end

  def set_time(%Timed{args: args} = entry, time_type) do
    date_time = Keyword.take(args, [:date, :time])
    time = parse_time(date_time)
           |> choose_time(time_type)

    case calc_datetime(date_time, time) do
      {:ok, datetime}   -> Map.put(entry, time_type, datetime)
      {:error, reason}  -> Map.update(entry, :errors, [reason], &(&1 ++ [reason]))
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

  defp choose_time([start_time, _], :start) do start_time end

  defp choose_time([_, end_time], :end) do end_time end
end
