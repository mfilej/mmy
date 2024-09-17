defmodule Ridle.Game do
  import Ecto.Query, warn: false

  alias Ridle.Repo
  alias Ridle.Game.Round

  def find_round(id) do
    Repo.get_by!(Round, id: id)
  end

  def list_round_numbers do
    from(r in Round, select: r.id, order_by: [asc: r.id])
    |> Repo.all()
  end
end
