defmodule RidleWeb.HomeLiveTest do
  use RidleWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Ridle.Factories

  test "renders the game", %{conn: conn} do
    insert(:round, id: 46)

    {:ok, view, _html} = live(conn, "/46")

    assert view |> element("#guess-form button", "Guess")
  end

  test "submits the correct guess", %{conn: conn} do
    insert(:round, id: 46, make: "porsche", model: "911", year_start: 1970, year_end: 1975)

    {:ok, view, _html} = live(conn, "/46")

    assert view
           |> form("#guess-attempt-form", %{
             "guess_attempt" => %{"make" => "Porsche", "model" => "911", "year" => 1970}
           })
           |> render_submit() =~ "Correct!"
  end

  test "submits two wrong guesses", %{conn: conn} do
    insert(:round, id: 46, make: "porsche", model: "911", year_start: 1970, year_end: 1975)

    {:ok, view, _html} = live(conn, "/46")

    view
    |> form("#guess-attempt-form", %{
      "guess_attempt" => %{"make" => "BMW", "model" => "M3", "year" => "1980"}
    })
    |> render_submit()

    html = render(view)
    assert [_] = find_guesses(html)

    view
    |> form("#guess-attempt-form", %{
      "guess_attempt" => %{"make" => "Ferrari", "model" => "F40", "year" => "1990"}
    })
    |> render_submit()

    html = render(view)
    assert [_, _] = find_guesses(html)
  end

  test "fails after 5 wrong guesses", %{conn: conn} do
    insert(:round, id: 46, make: "porsche", model: "911", year_start: 1970, year_end: 1975)

    {:ok, view, _html} = live(conn, "/46")

    view |> guess("BMW", "M3", "1980")
    view |> guess("Ferrari", "Testarossa", "1980")
    view |> guess("Ford", "Escort", "1980")
    view |> guess("Alfa Romeo", "Spider", "1980")
    html = view |> guess("Porsche", "911", "1978")

    assert [_, _, _, _, _] = find_guesses(html)

    assert html =~ "Game Over"
  end

  defp guess(view, make, model, year) do
    view
    |> form("#guess-attempt-form", %{
      "guess_attempt" => %{"make" => make, "model" => model, "year" => year}
    })
    |> render_submit()
    |> then(fn _ -> render(view) end)
  end

  defp find_guesses(html) do
    html
    |> Floki.parse_document!()
    |> Floki.find("#guesses>div")
  end
end
