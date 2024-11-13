defmodule RidleWeb.HomeLiveTest do
  use RidleWeb.ConnCase

  import Phoenix.LiveViewTest
  import Ridle.Factories

  test "renders the game", %{conn: conn} do
    _round = insert(:round, id: 46)

    {:ok, view, _html} = live(conn, "/46")

    assert view |> element("#guess-form button", "Guess")
  end

  test "submits a guess", %{conn: conn} do
    _round =
      insert(:round, id: 46, make: "porsche", model: "911", year_start: 1970, year_end: 1975)

    {:ok, view, _html} = live(conn, "/46")

    assert view
           |> form("#guess-attempt-form", %{
             "guess_attempt" => %{"make" => "Porsche", "model" => "911", "year" => 1970}
           })
           |> render_submit() =~ "Correct!"
  end
end
