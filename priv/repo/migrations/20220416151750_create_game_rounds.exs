defmodule Ridle.Repo.Migrations.CreateGameRounds do
  use Ecto.Migration

  def change do
    create table(:game_rounds) do
      add :make, :string, null: false
      add :model, :string, null: false
      add :year_start, :integer, null: false
      add :year_end, :integer, null: true

      add :image_url, :text, null: false

      timestamps()
    end
  end
end
