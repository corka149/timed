defmodule Timed.Cli.Log do


  @spec error(bitstring()) :: :ok
  def error(message) do
    [:red, message]
    |> log()
  end

  @spec warn(bitstring()) :: :ok
  def warn(message) do
    [:orange, message]
    |> log()
  end

  @spec info(bitstring()) :: :ok
  def info(message) do
    [:green, message]
    |> log()
  end

  defp log(message) do
    message
    |> Bunt.ANSI.format
    |> IO.puts
  end
end
