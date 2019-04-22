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

  @doc """
  Reads a timed-CSV which can be find by the given path
  """
  def read_db(path) do
    case File.read(path) do
      {:ok, data}       -> {:ok, convert_content(data)}
      {:error, reason}  -> {:error, reason}
    end
  end

  @doc """
  Splits the content to a list of row and column.
  """
  def convert_content(data) do
    data = String.split(data, "\n")
    for line <- data, String.contains?(line, ","), do: String.split(line, ",")
  end

  def convert_rows(splitted_rows) do
    Enum.filter(splitted_rows, &(length(&1) == 5))
    |> Enum.map(&convert_line/1)
  end

  def convert_line([date, start_time, end_time, break, note]) do
    args = [date: date, time: "#{start_time}~#{end_time}", break: break, note: note]
    Timed.new(args)
  end

  def convert_line(_) do
    Logger.error("Couldn't convert entry")
    {:error, :wrong_column_amount}
  end
end
