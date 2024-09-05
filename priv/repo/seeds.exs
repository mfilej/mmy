# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Ridle.Repo.insert!(%Ridle.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

[
  [
    image_url: "https://i.imgur.com/jDoOi9b.jpg",
    make: "ferrari",
    model: "f355",
    year_end: 1994,
    year_start: 1994
  ],
  [
    image_url: "https://i.imgur.com/XiAkpmz.jpg",
    make: "subaru",
    model: "justy",
    year_end: 1995,
    year_start: 1984
  ],
  [
    image_url: "https://i.imgur.com/n9VLQak.jpg",
    make: "pagani",
    model: "zonda",
    year_end: 2013,
    year_start: 1999
  ],
  [
    image_url: "https://i.imgur.com/iLEJWBO.jpg",
    make: "bugatti",
    model: "veyron",
    year_end: 2015,
    year_start: 2005
  ],
  [
    image_url: "https://i.imgur.com/aV8RmzR.jpg",
    make: "lamborghini",
    model: "lm002",
    year_end: 1993,
    year_start: 1986
  ],
  [
    image_url: "https://i.imgur.com/FjgtSDH.jpg",
    make: "ford",
    model: "escort",
    year_end: 1995,
    year_start: 1990
  ],
  [
    image_url: "https://i.imgur.com/8icccId.jpg",
    make: "dodge",
    model: "viper",
    year_end: 1995,
    year_start: 1991
  ]
]
|> Enum.each(fn attrs -> Ridle.Repo.insert!(struct(Ridle.Game.Round, attrs)) end)
