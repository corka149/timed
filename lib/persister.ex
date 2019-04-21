defmodule Timed.Persister do

  require Logger

  @doc """
  Checks if $HOME/.timed.csv is available
  """
  @spec is_csv_available?() :: boolean()
  def is_csv_available?() do
    case System.get_env("HOME") do
      nil   -> !Logger.error("No HOME environment variable set.")
      path  -> File.exists?(path <> "/.timed.csv")
    end
  end

end
