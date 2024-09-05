defmodule Ridle.Game do
  import Ecto.Query, warn: false

  alias Ridle.Repo
  alias Ridle.Game.Round

  def round(id) do
    Repo.get_by!(Round, id: id)
  end

  def rounds do
    Repo.all(Round)
  end
end
