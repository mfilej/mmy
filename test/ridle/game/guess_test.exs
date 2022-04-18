defmodule Ridle.Game.GuessTest do
  use Ridle.DataCase, async: true

  alias Ridle.Game.Guess

  test "normalizes make and model" do
    assert %Ecto.Changeset{changes: %{make: "astonmartin", model: "db9"}} =
             Guess.changeset(%Guess{}, %{make: "Aston Martin", model: "DB 9"})

    assert %Ecto.Changeset{changes: %{make: "rollsroyce", model: "phantom"}} =
             Guess.changeset(%Guess{}, %{make: "Rolls-Royce", model: "Phantom"})
  end
end
