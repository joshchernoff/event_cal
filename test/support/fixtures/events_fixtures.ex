defmodule EventCal.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EventCal.Events` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        description: "some description",
        event_date_time: ~N[2024-12-07 04:57:00],
        title: "some title"
      })
      |> EventCal.Events.create_event()

    event
  end
end
