defmodule EventCalWeb.Live.Index do
  use EventCalWeb, :live_view

  alias Phoenix.LiveView.Socket

  def mount(_params, _session, socket) do
    {:ok, assign(socket, timezone: nil)}
  end

  def handle_params(%{"year" => year, "month" => month}, _uri, socket) do
    with {:ok, date} <- parse_date(year, month) do
      now = Timex.now(socket.assigns.timezone || "UTC")
      {:noreply, assign_month_data(socket, now, date)}
    else
      _error ->
        {:noreply, push_patch(socket, to: "/#{Timex.format!(Timex.now(), "{YYYY}/{0M}")}")}
    end
  end

  def handle_params(_params, _uri, socket) do
    now = Timex.now(socket.assigns.timezone || "UTC")
    push_patch_to_month(socket, now)
  end

  def handle_event("set_timezone", %{"timezone" => timezone}, socket) do
    now = Timex.format!(Timex.now(timezone), "{0M}/{0D}/{YY} {h12}:{m} {AM}")

    {:noreply,
     socket
     |> assign_month_data(
       Timex.now(timezone),
       parse_month!(socket.assigns.current_month, socket.assigns.current_month_year)
     )
     |> assign(timezone: timezone, now: now)}
  end

  def handle_event("prev-month", _params, socket) do
    shift_month(socket, -1)
  end

  def handle_event("next-month", _params, socket) do
    shift_month(socket, 1)
  end

  defp shift_month(%Socket{} = socket, direction) do
    current_month = parse_month!(socket.assigns.current_month, socket.assigns.current_month_year)
    updated_month = Timex.shift(current_month, months: direction)
    push_patch_to_month(socket, updated_month)
  end

  defp push_patch_to_month(%Socket{} = socket, date) do
    {:noreply,
     socket
     |> assign_month_data(Timex.now(socket.assigns.timezone || "UTC"), date)
     |> push_patch(to: ~p"/#{Timex.format!(date, "{YYYY}")}/#{Timex.format!(date, "{0M}")}")}
  end

  defp assign_month_data(socket, now, current_month) do
    next_month = Timex.shift(current_month, months: 1)

    assign(socket,
      now: Timex.format!(now, "{0M}/{0D}/{YY} {h12}:{m} {AM}"),
      current_month: Timex.format!(current_month, "{Mfull}"),
      next_month: Timex.format!(next_month, "{Mfull}"),
      current_month_year: Timex.format!(current_month, "{YYYY}"),
      next_month_year: Timex.format!(next_month, "{YYYY}"),
      current_cal: generate_calendar_days(current_month, now),
      next_cal: generate_calendar_days(next_month, now)
    )
  end

  defp parse_date(year, month) do
    case Timex.parse("#{year}-#{month}-01", "{YYYY}-{0M}-{0D}") do
      {:ok, date} -> {:ok, date}
      _error -> {:error, :invalid_date}
    end
  end

  defp parse_month!(month, year) do
    Timex.parse!("#{month} 1, #{year}", "{Mfull} {D}, {YYYY}")
  end

  defp generate_calendar_days(date, now) do
    first_date = Timex.beginning_of_month(date)
    last_date = Timex.end_of_month(date)

    start_date = adjust_start_date(first_date)
    end_date = adjust_end_date(last_date)

    Date.range(start_date, end_date)
    |> Enum.map(&classify_day(&1, first_date, last_date, now))
  end

  defp adjust_start_date(first_date) do
    first_date |> Date.add(-Timex.weekday(first_date) |> rem(7))
  end

  defp adjust_end_date(last_date) do
    last_date |> Date.add(6 - rem(Date.day_of_week(last_date), 7))
  end

  defp classify_day(day, first_date, last_date, now) do
    if Date.compare(day, first_date) == :lt or Date.compare(day, last_date) == :gt do
      {:outside, day.day}
    else
      if Date.compare(day, now) == :eq do
        {:today, day.day}
      else
        {:inside, day.day}
      end
    end
  end
end
