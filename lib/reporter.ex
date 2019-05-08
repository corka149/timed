defmodule Timed.Reporter do

  require Logger

  @doc """
  Checks a list of timed structures and search for the entry which of the current day.
  For this entry it will calculate and return the worked hours.
  """
  @spec get_hours_today(maybe_improper_list()) :: nil | float()
  def get_hours_today([]) do nil end

  def get_hours_today([head | tail]) do
    %{start: start} = head
    if NaiveDateTime.to_date(start) == Date.utc_today() do
      calc_worked_hours(head)
    else
      get_hours_today(tail)
    end
  end

  @doc """
  Calculates the difference between expected sum of hours and sum of actual hours


  ## Examples

      iex> t1 = %Timed{start: ~N/2019-02-11 08:00:00/, end: ~N/2019-02-11 18:00:00/, break: 60} # 1hr
      iex> t2 = %Timed{start: ~N/2019-02-12 07:30:00/, end: ~N/2019-02-12 17:30:00/, break: 30} # 1.5hr
      iex> timed_list = [t1, t2]
      iex> Timed.Reporter.calc_total_overtime timed_list
      2.5
  """
  @spec calc_total_overtime([Timed.t()]) :: number()
  def calc_total_overtime(timed_list) do
    expected_worked_hours = 8 * length(timed_list)
    actual_worked_hours = Enum.reduce(timed_list, 0, fn timed, acc -> calc_worked_hours(timed) + acc end)
    actual_worked_hours - expected_worked_hours
  end

  @doc """
  Calculates the worked time for the given timed structure.


  ## Examples

      iex> timed = %Timed{start: ~N[2019-04-01 08:00:00], end: ~N[2019-04-01 17:00:00], break: 30}
      iex> Timed.Reporter.calc_worked_hours timed
      8.5
  """
  @spec calc_worked_hours(Timed.t()) :: float()
  def calc_worked_hours(%Timed{start: start_datetime, end: end_datetime, break: break}) do
    diff_seconds = NaiveDateTime.diff end_datetime, start_datetime
    (diff_seconds / 60 / 60) - (break / 60)
  end

  @doc """
  Works like IO.inspect. It takes a list of time structs, calculates total overtime and worked hours today
  and return the provided, untouched list.
  """
  def log_statistics(timed_list) do
    timed_list
    |> log_hours_today()
    |> log_total_overtime()
  end

  # ===== Convenience wrapper for logging =====

  # Wrapper for piping
  def log_total_overtime(timed_list) do
    overtime = calc_total_overtime(timed_list)
    Logger.info("Overtime: #{overtime} hrs")
    timed_list
  end

  # Wrapper for piping
  defp log_hours_today(timed_list) do
    worked_hours = get_hours_today(timed_list)
    Logger.info("Hours today: #{worked_hours} hrs")
    timed_list
  end
end
