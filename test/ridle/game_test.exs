defmodule Ridle.GameTest do
  use Ridle.DataCase, async: true

  import Ridle.Factories

  alias Ridle.Game

  describe "offer_guess/2" do
    test "random guess, guesses nothing correctly" do
      round = build(:round)

      {:ok, outcome} =
        Game.offer_guess(round, 1, %{"make" => "asdf", "model" => "asdf", "year" => 1919})

      refute outcome.make.correct?
      refute outcome.model.correct?
      refute outcome.year.correct?

      refute outcome.correct?
      assert outcome.id == 1
    end

    test "guesses the make" do
      round = build(:round, make: "bmw", model: "m3", year_start: 1992, year_end: 1999)

      {:ok, outcome} =
        Game.offer_guess(round, 1, %{"make" => "BMW", "model" => "M5", "year" => 1990})

      assert outcome.make.correct?

      refute outcome.model.correct?
      refute outcome.year.correct?
      refute outcome.correct?
    end

    test "guesses everything correctly" do
      round = build(:round, make: "citroen", model: "ds", year_start: 1955, year_end: 1975)

      {:ok, outcome} =
        Game.offer_guess(round, 1, %{"make" => "Citroen", "model" => "DS", "year" => 1970})

      assert outcome.make.correct?
      assert outcome.model.correct?
      assert outcome.year.correct?
      assert outcome.correct?
    end

    test "guess does not pass validations" do
      round = build(:round)

      assert {:error, %Ecto.Changeset{valid?: false} = changeset} =
               Game.offer_guess(round, 1, %{"make" => "", "model" => "", "year" => 500})

      assert changeset.errors[:year]
      assert changeset.errors[:model]
      assert changeset.errors[:year]
    end
  end
end
