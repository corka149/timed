defmodule Timed.Cli do
  require Logger

  @moduledoc """
    Is the user interface which can be controlled via the command line interface.
  """

  @doc """
    Entry point of application
  """
  def main(args \\ []) do
    {parsed, _, invalid} = parse_args(args)

    if (length(invalid) == 0) do
      IO.inspect process_args(parsed)
    else
      Logger.error(inspect(invalid))
      IO.puts(help())
    end
  end

  def process_args(args) do
    %Timed{}
    |> Timed.set_start(args)
    |> Timed.set_end(args)
    |> Timed.set_note(args)
    |> Timed.set_break(args)
  end

  @doc """
    Parses the Cli args and parse it to a key map.
  """
  def parse_args(args) do
    {aliases, strict} = allowed_args()
    OptionParser.parse(args, aliases: aliases, strict: strict)
  end

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
  def allowed_args do
    {[], []}
    |> interactive_arg
    |> date_arg
    |> time_arg
    |> break_arg
    |> note_arg
  end

  defp interactive_arg({aliases, strict}) do
    {aliases ++ [i: :interactive], strict ++ [interactive: :boolean]}
  end

  defp date_arg({aliases, strict}) do
    {aliases ++ [d: :date], strict ++ [date: :string]}
  end

  defp time_arg({aliases, strict}) do
    {aliases ++ [t: :time], strict ++ [time: :string]}
  end

  defp break_arg({aliases, strict}) do
    {aliases ++ [b: :break], strict ++ [break: :integer]}
  end

  defp note_arg({aliases, strict}) do
    {aliases ++ [n: :note], strict ++ [note: :string]}
  end
end
