defmodule Timed.Reporter do

  require Logger

  def log_hours_today([]) do nil end

  def log_hours_today([head | tail]) do
    if NaiveDateTime.to_date(head) == Date.utc_today() do
      worked_hours =  calc_worked_hours(head)
      Logger.info("Hours today: #{worked_hours}")
    else
      log_hours_today(tail)
    end
  end

  def log_overtime(timed_list) do
    expected_worked_hours = 8 * length(timed_list)
    actual_worked_hours = Enum.reduce(timed_list, fn timed, acc -> calc_worked_hours(timed) + acc end)
    overtime = expected_worked_hours - actual_worked_hours
    Logger.info("Overtime: #{overtime}")
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
