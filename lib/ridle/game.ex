defmodule Ridle.Game do
  import Ecto.Query, warn: false

  alias Ridle.Repo
  alias Ridle.Game.GuessAttempt
  alias Ridle.Game.GuessOutcome
  alias Ridle.Game.Round

  def find_round(id) do
    Repo.get_by!(Round, id: id)
  end

  def list_round_numbers do
    from(r in Round, select: r.id, order_by: [asc: r.id])
    |> Repo.all()
  end

  def initial_guess do
    GuessAttempt.new() |> GuessAttempt.changeset(%{})
  end

  def offer_guess(%Round{} = round, attrs) do
    changeset =
      GuessAttempt.new()
      |> GuessAttempt.changeset(attrs)
      |> Ecto.Changeset.apply_action(:validate)

    case changeset do
      {:ok, %GuessAttempt{} = attempt} ->
        {:ok, to_outcome(round, attempt)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp to_outcome(%Round{} = round, %GuessAttempt{make: make, model: model, year: year}) do
    outcome =
      %GuessOutcome{
        make: outcome(:make, round, make),
        model: outcome(:model, round, model),
        year: outcome(:year, round, year)
      }

    %{
      outcome
      | correct?: outcome.make.correct? && outcome.model.correct? && outcome.year.correct?
    }
  end

  defp outcome(:year, %Round{year_start: year_start, year_end: year_end}, guessed_year) do
    hint =
      cond do
        guessed_year > year_end -> :gt
        guessed_year < year_start -> :lt
        true -> nil
      end

    %GuessOutcome.Field{value: guessed_year, correct?: hint == nil, hint: hint}
  end

  defp outcome(field, %Round{} = round, guessed_value) do
    %{value: guessed_value, correct?: guessed_value == Map.fetch!(round, field), hint: nil}
  end
end
