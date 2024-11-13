defmodule Ridle.Factories do
  use ExMachina.Ecto, repo: Ridle.Repo

  def round_factory do
    year = Enum.random(1960..2010)

    %Ridle.Game.Round{
      make: sequence(:make, ~w[porsche fiat peugeot]),
      model: sequence(:model, ~w[911 124 106]),
      year_start: year,
      year_end: year + 5,
      image_url: sequence(:image_url, &"https://classic.cars/#{&1}.jpg")
    }
  end
end
