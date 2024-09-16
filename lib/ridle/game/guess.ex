defmodule Ridle.Game.Guess do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :id, :binary_id
    field :make, :string
    field :model, :string
    field :year, :integer
  end

  @castable_attrs ~w[make model year]a
  @required_attrs ~w[id make model year]a

  def new do
    %__MODULE__{id: Ecto.UUID.generate()}
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, @castable_attrs)
    |> update_change(:make, &normalize/1)
    |> update_change(:model, &normalize/1)
    |> validate_required(@required_attrs)
    |> validate_number(:year, less_than: 10_000, greater_than: 1_000)
  end

  defp normalize(string) do
    string
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\/]/, "")
  end
end
