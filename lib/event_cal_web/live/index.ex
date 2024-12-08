defmodule EventCalWeb.Live.Index do
  use EventCalWeb, :live_view

  def mount(_params, _session, socket) do
    now = Timex.now("UTC")
    next_month = Timex.shift(now, months: 1)

    current_cal = generate_calendar_days(now)
    next_cal = generate_calendar_days(next_month)

    {:ok,
     socket
     |> assign(
       timezone: nil,
       current_month: now |> Timex.format!("{Mfull}"),
       next_month: next_month |> Timex.format!("{Mfull}"),
       current_month_year: Timex.format!(now, "{YYYY}"),
       next_month_year: Timex.format!(next_month, "{YYYY}"),
       now: now |> Timex.format!("{0M}/{0D}/{YY} {h12}:{m} {AM}"),
       current_cal: current_cal,
       next_cal: next_cal
     )}
  end

  def handle_event("set_timezone", %{"timezone" => timezone}, socket) do
    now = Timex.now(timezone)
    next_month = Timex.shift(now, months: 1)

    current_cal = generate_calendar_days(now)
    next_cal = generate_calendar_days(next_month)

    {:noreply,
     assign(socket,
       timezone: timezone,
       current_month: now |> Timex.format!("{Mfull}"),
       next_month: next_month |> Timex.format!("{Mfull}"),
       current_month_year: Timex.format!(now, "{YYYY}"),
       next_month_year: Timex.format!(next_month, "{YYYY}"),
       now: now |> Timex.format!("{0M}/{0D}/{YY} {h12}:{m} {AM}"),
       current_cal: current_cal,
       next_cal: next_cal
     )}
  end

  def handle_event("prev-month", _unsigned_params, socket) do
    now = Timex.now(socket.assigns.timezone)

    current_month =
      Timex.parse!(
        "#{socket.assigns.current_month} 1, #{socket.assigns.current_month_year}",
        "{Mfull} {D}, {YYYY}"
      )
      |> Timex.shift(months: -1)

    next_month = current_month |> Timex.shift(months: 1)

    current_cal = generate_calendar_days(current_month)
    next_cal = generate_calendar_days(next_month)

    {:noreply,
     assign(socket,
       current_month: current_month |> Timex.format!("{Mfull}"),
       next_month: socket.assigns.current_month,
       current_month_year: Timex.format!(current_month, "{YYYY}"),
       next_month_year: socket.assigns.current_month_year,
       now: now |> Timex.format!("{0M}/{0D}/{YY} {h12}:{m} {AM}"),
       current_cal: current_cal,
       next_cal: next_cal
     )}
  end

  def handle_event("next-month", _unsigned_params, socket) do
    now = Timex.now(socket.assigns.timezone)

    next_month =
      Timex.parse!(
        "#{socket.assigns.next_month} 1, #{socket.assigns.next_month_year}",
        "{Mfull} {D}, {YYYY}"
      )
      |> Timex.shift(months: 1)

    next_cal = generate_calendar_days(next_month)
    current_cal = next_month |> Timex.shift(months: -1) |> generate_calendar_days()

    {:noreply,
     assign(socket,
       current_month: socket.assigns.next_month,
       current_month_year: socket.assigns.next_month_year,
       next_month: next_month |> Timex.format!("{Mfull}"),
       next_month_year: Timex.format!(next_month, "{YYYY}"),
       now: now |> Timex.format!("{0M}/{0D}/{YY} {h12}:{m} {AM}"),
       current_cal: current_cal,
       next_cal: next_cal
     )}
  end

  defp generate_calendar_days(date) do
    first_date = Timex.beginning_of_month(date)

    start_date =
      date
      |> Timex.beginning_of_month()
      |> Date.add(-(Timex.weekday(first_date) |> rem(7)))

    last_date = Timex.end_of_month(date)

    end_date =
      date
      |> Timex.end_of_month()
      |> Date.add(6 - rem(Date.day_of_week(last_date), 7))

    days = Enum.to_list(Date.range(start_date, end_date))

    Enum.map(days, fn day ->
      if Date.compare(day, first_date) in [:lt] or Date.compare(day, last_date) in [:gt] do
        {:outside, day.day}
      else
        {:inside, day.day}
      end
    end)
  end
end
