defmodule Timed.Cli do
  require Logger

  @moduledoc """
    Is the user interface which can be controlled via the command line interface.
  """

  @doc """
    Entry point of application
  """
  @spec main([binary()]) :: any()
  def main(args \\ []) do
    {parsed, _, _} = args = parse_args(args)

    if args_valid?(args) do
      Timed.new(parsed)
      |> Timed.Persister.update_db()
    else
      Logger.error "One or more arguments are invalid. Please check usage."
      IO.puts(help())
    end
  end

  @doc """
    Parses the Cli args and parse it to a key map.
  """
  @spec parse_args([binary()]) :: {keyword(), [binary()], [{binary(), nil | binary()}]}
  def parse_args(args) do
    {aliases, strict} = allowed_args()
    OptionParser.parse(args, aliases: aliases, strict: strict)
  end

  @doc """
  Prints the help how to use timed
  """
  @spec help() :: <<_::5632>>
  def help() do
    ~s"""
    Manages your working times.

    Usage:
      -d, --date          Takes the date that should be used. Format: "yyyy-mm-dd" -> E.g.
                          2019-03-28. When not provided, it will use the current date.
      -t, --time          Can take start and/or end. Format "hh:mm" -> E.g. "08:00~17:00",
                          "~16:45", "07:30~". When no entry exists, it will use the current
                          time for the missing time.
      -b, --break         Takes the duration of the break in minutes. Default: 0min
      -n, --note          Takes a note and add it to an entry.

    Data:
      Timed data is stored in "$HOME/.timed.csv". The columns are structured the following way:
      date, start, end, breaktime, note
    """
  end

  @doc """
    Defines the list of allowd arguments and their aliases.
  """
  @spec allowed_args() :: {[{any(), any()}, ...], [{any(), any()}, ...]}
  def allowed_args do
    {[], []}
    |> date_arg
    |> time_arg
    |> break_arg
    |> note_arg
  end

  def args_valid?({_, remaining, invalid}) when length(invalid) > 0 or length(remaining) > 0 do false end

  def args_valid?({parsed, _, _}) do
    valid_time =  Keyword.take(parsed, [:time])
                  |> is_valid_time?
    valid_date =  Keyword.take(parsed, [:date])
                  |> is_valid_date?

    valid_time and valid_date
  end

  # It is ok when no date argument is provided
  defp is_valid_date?([]) do true end

  defp is_valid_date?([date: date]) do
    {result, _} = Date.from_iso8601(date)
    :ok == result
  end

  defp is_valid_date?(_) do
    Logger.error("Date couldn't be validated.")
    false
  end

  # It is ok when no time argument is provided
  defp is_valid_time?([]) do true end

  defp is_valid_time?([time: time]) do
    {result, _} = Time.from_iso8601(time)
    :ok == result
  end

  defp is_valid_time?(_) do
    Logger.error("Time couldn't be validated.")
    false
  end

  defp date_arg({aliases, strict}) do
    {[{:d, :date} | aliases], [{:date, :string} | strict]}
  end

  defp time_arg({aliases, strict}) do
    {[{:t, :time} | aliases], [{:time, :string} | strict]}
  end

  defp break_arg({aliases, strict}) do
    {[{:b, :break} | aliases], [{:break, :integer} | strict]}
  end

  defp note_arg({aliases, strict}) do
    {[{:n, :note} | aliases], [{:note, :string} | strict]}
  end
end
