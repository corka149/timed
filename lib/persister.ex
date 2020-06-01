defmodule Timed.Persister do
  alias Timed.Cli.Log

  alias Timed.Reporter

  @doc """
  Returns the path to the timed.csv-File.
  """
  @spec get_db_path() :: {:error, <<_::264>>} | {:ok, binary()}
  def get_db_path() do
    case System.get_env("HOME") do
      nil -> {:error, "No HOME environment variable set."}
      path -> {:ok, path <> "/.timed.csv"}
    end
  end

  @doc """
  Updates the database with the new entry. It will simply add it when no entry exists for the same date.
  Else it will start a dialog for selection of the right values.
  """
  def update_db(new_entry) do
    create_db(get_db_path())

    case get_db_path() do
      {:ok, path} ->
        read_db(path)
        |> update_entries(new_entry)
        |> Reporter.log_statistics()
        |> save_db(path)

      {:error, message} ->
        Log.error(message)
    end
  end

  @doc """
  Creates the inital database if path is available.
  """
  def create_db({:ok, path}) do
    unless File.exists?(path) do
      Log.info("Initial creation of database.")
      File.touch(path)
    end
  end

  def create_db({:error, _}) do
    Log.error("Couldn't create inital the database.")
  end

  @doc """
  Reads a timed-CSV which can be find by the given path.
  """
  def read_db(path) do
    case File.read(path) do
      {:ok, data} -> {:ok, convert_content(data)}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Saves back all entries to the database.
  """
  def save_db(entries, path) do
    content = Enum.reduce(entries, "", &"#{&2}#{Timed.to_str(&1)}\n")
    File.write(path, content)
  end

  def update_entries({:ok, entries}, new_entry) do
    case Enum.find(entries, fn other -> compare_timed_dates(other, new_entry) end) do
      nil -> [new_entry | entries]
      existing_entry -> update_existing_entry(existing_entry, new_entry, entries)
    end
  end

  def update_entries({:error, reason}, _) do
    Log.error("Couldn't perform an update. Reason: #{reason}")
  end

  def update_existing_entry(old, new, all_existing_entries) do
    merged = Map.merge(old, new, &update_only_different/3)

    [
      merged
      | Enum.filter(all_existing_entries, fn other -> !compare_timed_dates(other, merged) end)
    ]
  end

  @doc """
  Checks if the provided values are equal and forces to select one of them when they are not equal.
  Else it will return one of the equal values.
  """
  def update_only_different(key, val1, val2) do
    if val1 == val2 do
      val1
    else
      keep_or_update(key, val1, val2)
    end
  end

  def keep_or_update(:__struct__, _, _) do
    "Elixir.Timed"
  end

  # Old errors never exists
  def keep_or_update(:errors, _, new) do
    new
  end

  def keep_or_update(key, left, right) do
    Log.info("#{key} - (l)eft or (r)ight? '#{left}' - '#{right}'")

    answer =
      IO.read(2)
      |> String.first()

    if answer == "l" or answer == "r" do
      if answer == "l", do: left, else: right
    else
      keep_or_update(key, left, right)
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
    args = [
      date: date,
      time: "#{start_time}~#{end_time}",
      break: String.to_integer(break),
      note: note
    ]

    Timed.new(args)
  end

  def convert_row(_) do
    Log.warn("Couldn't convert entry")
    {:error, :wrong_column_amount}
  end

  def compare_timed_dates(_, %Timed{start: nil}) do
    false
  end

  def compare_timed_dates(%Timed{start: nil}, _) do
    false
  end

  def compare_timed_dates(%Timed{start: start1}, %Timed{start: start2}) do
    NaiveDateTime.to_date(start1) == NaiveDateTime.to_date(start2)
  end
end
