defmodule Ridle.Game.Guess do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :id, :binary_id
    field :make, :string
    field :model, :string
    field :year, :string
  end

  @castable_attrs ~w[make model year]a
  @required_attrs ~w[id make model year]a

  def new do
    %__MODULE__{id: Ecto.UUID.generate()}
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, @castable_attrs)
    |> validate_required(@required_attrs)
  end
end
