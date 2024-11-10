defmodule Ridle.GameTest do
  use Ridle.DataCase, async: true

  alias Ridle.Game

  defp insert_round(starts_at, make, model, year) do
    {:ok, _} =
      %Game.Round{
        starts_at: starts_at,
        make: make,
        model: model,
        year_start: year,
        year_end: year,
        image_url: "http://localhost/image.jpg"
      }
      |> Ridle.Repo.insert()
  end
end
