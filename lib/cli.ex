defmodule Timed.Cli do
  alias Timed.Cli.Log

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
      Log.warn("One or more arguments are invalid. Please check usage.")
      Log.info(help())
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
                        2019-03-28. Default: today

    -s, --start         Takes the start time. Format "hh:mm" -> E.g. "08:00". Default: now

    -e, --end           Parameter for end time. Format "hh:mm" -> E.g. "08:00". Default: now

    -b, --break         Takes the duration of the break in minutes. Default: 0min

    -n, --note          Takes a note and add it to an entry. Default: ""

    """
  end

  @doc """
    Defines the list of allowd arguments and their aliases.
  """
  @spec allowed_args() :: {[{any(), any()}, ...], [{any(), any()}, ...]}
  def allowed_args do
    {[], []}
    |> date_arg
    |> start_arg # time_arg
    |> end_arg
    |> break_arg
    |> note_arg
  end

  @doc """
  Checks if the parsed arguments are valid
  The strucure of the tuple looks like this: {parsed, remaining, invalid}

  ## Examples

      iex> parsed_args = {[date: "2018-11-11", end: "17:00"], [], []}
      iex> Timed.Cli.args_valid? parsed_args
      true
      iex> parsed_args = {[start: "07:00"], [], []}
      iex> Timed.Cli.args_valid? parsed_args
      true
      iex> invalid_parsed_args = {[start: "28:00", end: "29:10"], [], []}
      iex> Timed.Cli.args_valid? invalid_parsed_args
      false
  """
  @spec args_valid?({any(), any(), any()}) :: boolean()
  def args_valid?({_, remaining, invalid}) when length(invalid) > 0 or length(remaining) > 0 do
    false
  end

  def args_valid?({parsed, _, _}) do
    valid_start =
      Keyword.take(parsed, [:start])
      |> is_valid_time?

    valid_end =
      Keyword.take(parsed, [:end])
      |> is_valid_time?

    valid_date =
      Keyword.take(parsed, [:date])
      |> is_valid_date?

      valid_start and valid_end and valid_date
  end

  # It is ok when no date argument is provided
  defp is_valid_date?([]) do
    true
  end

  defp is_valid_date?(date: date) do
    {result, _} = Date.from_iso8601(date)

    unless :ok == result do
      Log.error("Invalid date format.")
    end

    :ok == result
  end

  defp is_valid_date?(_) do
    Log.warn("Date couldn't be validated.")
    false
  end

  # It is ok when no time argument is provided
  defp is_valid_time?([]) do
    true
  end

  defp is_valid_time?(args) do
    start_t = Keyword.get(args, :start, "")
    end_t = Keyword.get(args, :end, "")

    check = fn time, type ->
      {result, _} = Time.from_iso8601("#{time}:00")

      if :ok != result and 0 < String.length(time) do
        Log.error("Invalid time format for #{type} time (Invalid value: '#{time}').")
      end

      :ok == result
    end

    (check.(start_t, "starting") or start_t == "") and (check.(end_t, "ending") or end_t == "")
  end

  defp date_arg({aliases, strict}) do
    {[{:d, :date} | aliases], [{:date, :string} | strict]}
  end

  defp start_arg({aliases, strict}) do
    {[{:s, :start} | aliases], [{:start, :string} | strict]}
  end

  defp end_arg({aliases, strict}) do
    {[{:e, :end} | aliases], [{:end, :string} | strict]}
  end

  defp break_arg({aliases, strict}) do
    {[{:b, :break} | aliases], [{:break, :integer} | strict]}
  end

  defp note_arg({aliases, strict}) do
    {[{:n, :note} | aliases], [{:note, :string} | strict]}
  end
end
