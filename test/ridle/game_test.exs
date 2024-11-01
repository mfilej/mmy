defmodule Ridle.GameTest do
  use Ridle.DataCase, async: true

  alias Ridle.Game

  test "returns today's round" do
    insert_round(~U[2022-04-14 00:00:00Z], "Renault", "Twingo", 1993)
    insert_round(~U[2022-04-15 00:00:00Z], "Opel", "Omega", 1990)
    insert_round(~U[2022-04-16 00:00:00Z], "Ford", "Capri", 1978)

    now = ~U[2022-04-15 22:55:00Z]

    assert %Game.Round{make: "Opel", model: "Omega", year_start: 1990} = Game.current_round(now)
  end

  test "returns newest round that is not in the future" do
    insert_round(~U[2022-04-14 00:00:00Z], "Renault", "Twingo", 1993)
    insert_round(~U[2022-04-16 00:00:00Z], "Ford", "Capri", 1978)

    now = ~U[2022-04-15 22:55:00Z]

    assert %Game.Round{make: "Renault", model: "Twingo", year_start: 1993} = Game.current_round(now)
  end

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
