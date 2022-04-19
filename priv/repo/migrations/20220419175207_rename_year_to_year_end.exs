defmodule Ridle.Repo.Migrations.RenameYearToYearEnd do
  use Ecto.Migration

  def change do
    rename table("game_rounds"), :year, to: :year_start

    alter table("game_rounds") do
      modify :year_end, :integer, null: true
    end
  end
end
