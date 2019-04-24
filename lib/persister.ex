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
  Updates the database with the new entry. It will simply add it when no entry exists for the same date.
  Else it will start a dialog for selection of the right values.
  """
  def update_db(new_entry) do
    create_db(get_db_path())
    case get_db_path() do
      {:ok, path} ->  read_db(path)
                      |> update_entries(new_entry)
                      |> save_db(path)
      {:error, message} -> Logger.error message
    end
  end

  @doc """
  Creates the inital database if path is available.
  """
  def create_db({:ok, path}) do
    if !File.exists?(path) do
      Logger.info "Initial creation of database."
      File.touch(path)
    end
  end

  def create_db({:error, _}) do
    Logger.error "Couldn't create inital the database."
  end

  @doc """
  Reads a timed-CSV which can be find by the given path.
  """
  def read_db(path) do
    case File.read(path) do
      {:ok, data}       -> {:ok, convert_content(data)}
      {:error, reason}  -> {:error, reason}
    end
  end

  @doc """
  Saves back all entries to the database.
  """
  def save_db(entries, path) do
    content = Enum.reduce(entries, "", &("#{&2}#{Timed.to_str(&1)}\n"))
    File.write(path, content)
  end

  def update_entries({:ok, entries}, new_entry) do
    case Enum.find(entries, fn other -> compare_timed_dates(other, new_entry) end) do
      nil             -> [new_entry | entries]
      existing_entry  -> update_existing_entry(existing_entry, new_entry, entries)
    end
  end

  def update_entries({:error, reason}, _) do
    Logger.error "Couldn't perform an update. Reason: #{reason}"
  end

  def update_existing_entry(old, new, all_existing_entries) do
    merged = Map.merge(old, new, &keep_or_update/3)
    [merged | Enum.filter(all_existing_entries, fn other -> compare_timed_dates(other, merged) end)]
  end

  def keep_or_update(key, v1, v2) do
    IO.puts(key <> " - (l)eft or (r)ight? #{v1} - #{v2}")
    answer = IO.read(1)
    if answer == "l" or answer == "r" do
      if answer == "l", do: v1, else: v2
    else
      keep_or_update(key, v1, v2)
    end
  end

  @doc """
  Splits the content to a list of row and column.
  """
  def convert_content(data) do
    data = String.split(data, "\n")
    data = for line <- data, String.contains?(line, ","), do: String.split(line, ",")

    convert_rows(data)
  end

  @doc """
  Takes a list of splitted rows and convert them to timed structs.
  """
  def convert_rows(splitted_rows) do
    Enum.filter(splitted_rows, &(length(&1) == 5))
    |> Enum.map(&convert_row/1)
  end

  @doc """
  Converts a row of a timed-CSV to a timed struct.


  ## Examples

      iex> row = ["2018-01-19", "07:50", "17:00", "45", ""]
      iex> Timed.Persister.convert_row(row)
      %Timed{
        break: 45,
        end: ~N[2018-01-19 17:00:00],
        errors: [],
        note: "",
        start: ~N[2018-01-19 07:50:00]
      }


  """
  def convert_row([date, start_time, end_time, break, note]) do
    args = [date: date, time: "#{start_time}~#{end_time}", break: break, note: note]
    Timed.new(args)
  end

  def convert_row(_) do
    Logger.error("Couldn't convert entry")
    {:error, :wrong_column_amount}
  end

  defp compare_timed_dates(entry1, entry2) do
    NaiveDateTime.to_date(entry1.start) == NaiveDateTime.to_date(entry2.start)
  end
end
