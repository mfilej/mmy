defmodule Ridle.Game do
  import Ecto.Query

  alias Ridle.Repo
  alias Ridle.Game.Round

  def current_round(now) do
    from(r in Round, where: r.starts_at < ^now, order_by: {:desc, r.starts_at}, limit: 1)
    |> Repo.one()
  end
end
