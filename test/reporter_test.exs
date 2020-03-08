defmodule Timed.ReporterTest do
  use ExUnit.Case
  doctest Timed.Reporter

  test "calc_total_overtime with three timed elements" do
    # 1hr
    t1 = %Timed{start: ~N/2019-03-01 07:30:00/, end: ~N/2019-03-01 17:00:00/, break: 30}
    # 0.5hr
    t2 = %Timed{start: ~N/2019-03-02 07:30:00/, end: ~N/2019-03-02 17:00:00/, break: 60}
    # 1 hr
    t3 = %Timed{start: ~N/2019-03-03 08:30:00/, end: ~N/2019-03-03 18:00:00/, break: 30}
    timed_list = [t1, t2, t3]
    overtime = Timed.Reporter.calc_total_overtime(timed_list)
    assert 2.5 == overtime
  end
end
