defmodule Ridle.Game.Round do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "game_rounds" do
    field :make, :string
    field :model, :string
    field :year_start, :integer
    field :year_end, :integer
    field :image_url, :string
    field :starts_at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(round, attrs) do
    round
    |> cast(attrs, [:make, :model, :year_start, :year_end, :image_url, :starts_at])
    |> validate_required([:make, :model, :year_start, :year_end, :image_url, :starts_at])
  end
end
