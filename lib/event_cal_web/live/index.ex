defmodule EventCalWeb.Live.Index do
  use EventCalWeb, :live_view

  def mount(_params, _session, socket) do
    now = Timex.now("UTC")
    {:ok, assign_month_data(socket, now, nil, Timex.beginning_of_month(now))}
  end

  def handle_event("set_timezone", %{"timezone" => timezone}, socket) do
    now = Timex.now(timezone)
    {:noreply, assign_month_data(socket, now, timezone, Timex.beginning_of_month(now))}
  end

  def handle_event("prev-month", _params, socket) do
    shift_month(socket, -1)
  end

  def handle_event("next-month", _params, socket) do
    shift_month(socket, 1)
  end

  def shift_month(socket, direction) do
    current_month = parse_month(socket.assigns.current_month, socket.assigns.current_month_year)
    updated_month = Timex.shift(current_month, months: direction)

    {:noreply,
     assign_month_data(
       socket,
       Timex.now(socket.assigns.timezone),
       socket.assigns.timezone,
       updated_month
     )}
  end

  defp assign_month_data(socket, now, timezone, current_month) do
    next_month = Timex.shift(current_month, months: 1)

    assign(socket,
      timezone: timezone,
      now: Timex.format!(now, "{0M}/{0D}/{YY} {h12}:{m} {AM}"),
      current_month: Timex.format!(current_month, "{Mfull}"),
      next_month: Timex.format!(next_month, "{Mfull}"),
      current_month_year: Timex.format!(current_month, "{YYYY}"),
      next_month_year: Timex.format!(next_month, "{YYYY}"),
      current_cal: generate_calendar_days(current_month),
      next_cal: generate_calendar_days(next_month)
    )
  end

  defp parse_month(month, year) do
    Timex.parse!("#{month} 1, #{year}", "{Mfull} {D}, {YYYY}")
  end

  defp generate_calendar_days(date) do
    first_date = Timex.beginning_of_month(date)
    last_date = Timex.end_of_month(date)

    start_date = adjust_start_date(first_date)
    end_date = adjust_end_date(last_date)

    Date.range(start_date, end_date)
    |> Enum.map(&classify_day(&1, first_date, last_date))
  end

  defp adjust_start_date(first_date) do
    first_date |> Date.add(-Timex.weekday(first_date) |> rem(7))
  end

  defp adjust_end_date(last_date) do
    last_date |> Date.add(6 - rem(Date.day_of_week(last_date), 7))
  end

  defp classify_day(day, first_date, last_date) do
    if Date.compare(day, first_date) == :lt or Date.compare(day, last_date) == :gt do
      {:outside, day.day}
    else
      {:inside, day.day}
    end
  end
end
