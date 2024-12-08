defmodule EventCal.Repo do
  use Ecto.Repo,
    otp_app: :event_cal,
    adapter: Ecto.Adapters.SQLite3
end
