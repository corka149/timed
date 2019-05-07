defmodule Timed.Reporter do

  require Logger

  def log_statistics(timed_list) do
    timed_list
    |> log_hours_today()
    |> log_overtime()
  end

  @doc """
  Logs to stdout the worked hours for today.
  """
  def log_hours_today(timed_list) do
    log_hours(timed_list)
    timed_list
  end

  defp log_hours([]) do nil end

  defp log_hours([head | tail]) do
    %{start: start} = head
    if NaiveDateTime.to_date(start) == Date.utc_today() do
      worked_hours =  calc_worked_hours(head)
      Logger.info("Hours today: #{worked_hours} hrs")
    else
      log_hours_today(tail)
    end
  end

  @doc """
  Logs to stdout the difference between expected sum of hours and sum of actual hours
  """
  def log_overtime(timed_list) do
    expected_worked_hours = 8 * length(timed_list)
    actual_worked_hours = Enum.reduce(timed_list, 0, fn timed, acc -> calc_worked_hours(timed) + acc end)
    overtime = actual_worked_hours - expected_worked_hours
    Logger.info("Overtime: #{overtime} hrs")
    timed_list
  end

  @doc """
  Calculates the worked time for the given timed structure.


  ## Examples

      iex> timed = %Timed{%Timed{} | start: ~N[2019-04-01 08:00:00]}
      iex> timed = %Timed{timed | end: ~N[2019-04-01 17:00:00]}
      iex> timed = %Timed{timed | break: 30}
      iex> Timed.Reporter.calc_worked_hours timed
      8.5
  """
  def calc_worked_hours(%Timed{start: start_datetime, end: end_datetime, break: break}) do
    diff_seconds = NaiveDateTime.diff end_datetime, start_datetime
    (diff_seconds / 60 / 60) - (break / 60)
  end
end
