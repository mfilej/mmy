defmodule Ridle.Repo.Migrations.CreateGameRounds do
  use Ecto.Migration

  def change do
    create table(:game_rounds, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :make, :string, null: false
      add :model, :string, null: false
      add :year, :integer, null: false

      add :image_url, :text, null: false

      add :starts_at, :utc_datetime, null: false

      timestamps()
    end
  end
end
