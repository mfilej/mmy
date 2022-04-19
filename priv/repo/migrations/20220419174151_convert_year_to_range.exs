defmodule Ridle.Repo.Migrations.ConvertYearToRange do
  use Ecto.Migration

  def change do
    alter table("game_rounds") do
      add :year_end, :integer
    end
  end
end
