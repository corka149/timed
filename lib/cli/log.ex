defmodule Timed.Cli.Log do
  @moduledoc """
  Simplistic wrapper around Bunt and IO.puts.
  """

  @doc """
  Writes an error message to console.
  """
  @spec error(bitstring()) :: :ok
  def error(message) do
    [:red, message]
    |> stderr()
  end

  @doc """
  Sends a warning to the terminal.
  """
  @spec warn(bitstring()) :: :ok
  def warn(message) do
    [:orange, message]
    |> stdout()
  end

  @doc """
  Prints an info the console.
  """
  @spec info(bitstring()) :: :ok
  def info(message) do
    [message]
    |> stdout()
  end

  defp stderr(message) do
    message = Bunt.ANSI.format(message)
    IO.puts(:stderr, message)
  end

  defp stdout(message) do
    message
    |> Bunt.ANSI.format()
    |> IO.puts()
  end
end
