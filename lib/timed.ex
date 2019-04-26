defmodule Timed do
  @moduledoc """
  Bundles functions around transforming working times.
  """

  defstruct start: nil, end: nil, note: "", break: 0, errors: []

  @doc """
  Creates a new Timed entry.
  """
  @spec new(keyword()) :: any()
  def new(args) do
    %Timed{}
    |> Timed.set_start(args)
    |> Timed.set_end(args)
    |> Timed.set_note(args)
    |> Timed.set_break(args)
  end

  @doc """
  Sets the break in minutes provided via args
  """
  @spec set_break(any(), keyword()) :: any()
  def set_break(entry, args) do
    case Keyword.take(args, [:break]) do
       [break: minutes] -> %Timed{entry | break: minutes}
        _______________ -> entry
    end
  end

  @doc """
  Set the note given through the args
  """
  @spec set_note(any(), keyword()) :: any()
  def set_note(entry, args) do
    case Keyword.take(args, [:note]) do
       [note: text] -> %Timed{entry | note: text}
        _           -> entry
    end
  end

  @doc """
  Sets the start time and date.
  """
  @spec set_start(map(), keyword()) :: map()
  def set_start(entry, args) do
    set_time(entry, args, :start)
  end

  @doc """
  Sets the end time and date.
  """
  @spec set_end(map(), keyword()) :: map()
  def set_end(entry, args) do
    set_time(entry, args, :end)
  end

  @spec set_time(map(), keyword(), :end | :start) :: map()
  def set_time(entry, args, time_type) do
    date_time = Keyword.take(args, [:date, :time])
    time = parse_time(date_time)
           |> choose_time(time_type)

    case calc_datetime(date_time, time) do
      {:ok, datetime}   -> Map.put(entry, time_type, datetime)
      {:error, reason}  -> add_error(entry, reason)
    end
  end

  @doc """
  Converts a timed struct to a string


  ## Examples

      iex> row = ["2018-01-19", "07:50", "17:00", "45", ""]
      iex> entry = Timed.Persister.convert_row(row)
      iex> Timed.to_str(entry)
      "2018-01-19,07:50,17:00,45,"
  """
  @spec to_str(Timed.t()) :: <<_::32, _::_*8>>
  def to_str(%Timed{break: break, start: start, end: end_datetime, note: note}) do
    date = NaiveDateTime.to_date(start)
           |> Date.to_string
    start_time = hours_and_minutes(start)
    end_time = hours_and_minutes(end_datetime)

    "#{date},#{start_time},#{end_time},#{break},#{note}"
  end

  def calc_datetime([date: date], "") do
    time = Time.utc_now()
    case Date.from_iso8601(date) do
      {:ok, date} -> NaiveDateTime.new(date, time)
      {result, reason}  -> {result, reason}
    end
  end

  def calc_datetime([date: date, time: _], "") do
    time = Time.utc_now()
    case Date.from_iso8601(date) do
      {:ok, date} -> NaiveDateTime.new(date, time)
      {result, reason}  -> {result, reason}
    end
  end

  def calc_datetime([date: date, time: _], time) do
    NaiveDateTime.from_iso8601("#{date} #{time}:00")
  end

  def calc_datetime([time: _], time) do
    date = Date.utc_today()
    case Time.from_iso8601(time <> ":00") do
      {:ok, time} -> NaiveDateTime.new(date, time)
      {result, reason}  -> {result, reason}
    end
  end

  def calc_datetime(_, _) do
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

  defp add_error(%Timed{errors: errors} = entry, new_error) do
    %Timed{entry | errors: [new_error | errors]}
  end

  defp hours_and_minutes(datetime) do
    {hrs_min, _} = datetime
    |> DateTime.to_time
    |> Time.to_string
    |> String.split_at(5)

    hrs_min
  end
end
