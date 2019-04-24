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
    {parsed, _, invalid} = parse_args(args)

    if (length(invalid) == 0 and length(parsed) > 0) do
      Timed.new(parsed)
      |> Timed.Persister.update_db()
    else
      Logger.error(inspect(invalid))
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
  @spec help() :: <<_::6296>>
  def help() do
    ~s"""
    Manages your working times.

    Usage:
      -i, --interactive   Guides through all steps of creating or editing a new entry.
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
    |> interactive_arg
    |> date_arg
    |> time_arg
    |> break_arg
    |> note_arg
  end

  defp interactive_arg({aliases, strict}) do
    {[{:i, :interactive} | aliases], [{:interactive, :boolean} | strict]}
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
