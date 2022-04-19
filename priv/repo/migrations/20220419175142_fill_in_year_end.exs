defmodule Ridle.Repo.Migrations.FillInYearEnd do
  use Ecto.Migration

  import Ecto.Query

  def change do
    from(r in "game_rounds", update: [set: [year_end: r.year]])
    |> Ridle.Repo.update_all([])
  end
end
