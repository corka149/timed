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
  def help() do
    ~s"""

    Description:
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

  @doc """
  Checks if the parsed arguments are valid
  The strucure of the tuple looks like this: {parsed, remaining, invalid}

  ## Examples

      iex> parsed_args = {[date: "2018-11-11", time: "~17:00"], [], []}
      iex> Timed.Cli.args_valid? parsed_args
      true
      iex> parsed_args = {[time: "07:00~"], [], []}
      iex> Timed.Cli.args_valid? parsed_args
      true
      iex> invalid_parsed_args = {[time: "28:00~29:10"], [], []}
      iex> Timed.Cli.args_valid? invalid_parsed_args
      false
  """
  @spec args_valid?({any(), any(), any()}) :: boolean()
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

  defp is_valid_time?(args) do
    [start_t, end_t] = Timed.parse_time(args)
    {result_start, _} = Time.from_iso8601("#{start_t}:00")
    {result_end, _} = Time.from_iso8601("#{end_t}:00")
    (:ok == result_start or start_t == "") and (:ok == result_end or end_t == "")
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
