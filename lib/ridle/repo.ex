defmodule Ridle.Repo do
  use Ecto.Repo,
    otp_app: :ridle,
    adapter: Ecto.Adapters.SQLite3
end
