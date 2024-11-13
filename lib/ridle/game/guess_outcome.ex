defmodule Ridle.Game.GuessOutcome do
  defmodule Field do
    defstruct [:value, :correct?, :hint]
  end

  defstruct [:id, :make, :model, :year, :correct?]
end
