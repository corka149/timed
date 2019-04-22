defmodule Timed.Persister do

  require Logger

  @doc """
  Returns the path to the timed.csv-File.
  """
  @spec get_db_path() :: {:error, <<_::264>>} | {:ok, binary()}
  def get_db_path() do
    case System.get_env("HOME") do
      nil   -> {:error, "No HOME environment variable set."}
      path  -> {:ok, path <> "/.timed.csv"}
    end
  end

  def read_db({:ok, path}) do
    case File.read(path) do
      {:ok, data}       -> {:ok, convert_content(data)}
      {:error, reason}  -> {:error, reason}
    end
  end

  def read_db({:error, reason}) do
    Logger.error("Couldn't open database. Reason: " <> reason)
  end

  @doc """
  Splits the content to a list of row and column.
  """
  @spec convert_content(any()) :: [any()]
  def convert_content(data) do
    data = String.split(data, "\n")
    for line <- data, String.contains?(line, ","), do: String.split(line, ",")
  end

  def convert_to_entries(rows_and_columns) do
    Enum.map(rows_and_columns, &convert_line/1)
  end

  def convert_line([date, start_time, end_time, break, note]) do
    args = [date: date, time: "#{start_time}~#{end_time}", break: break, note: note]

    %Timed{}
    Timed.Cli.process_args(args)
  end
end
