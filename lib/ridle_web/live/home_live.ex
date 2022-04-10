defmodule RidleWeb.HomeLive do
  use RidleWeb, :live_view

  alias Ridle.Game

  def mount(_params, _session, socket) do
    solution = %{make: "ford", model: "capri", year: 1978}

    initial_guesses = []
    # initial_guesses = [
    #   %{
    #     id: "cec590b2-9cd5-4ba7-85e4-c7a50262390f",
    #     make: %{v: "Aston Martin"},
    #     model: %{v: "DBS"},
    #     year: %{v: "2008"}
    #   },
    #   %{
    #     id: "cec590b2-9cd5-4ba7-85e4-c7a50262390e",
    #     make: %{v: "Ford"},
    #     model: %{v: "Capri"},
    #     year: %{v: "1978"}
    #   }
    # ]

    changeset = guess_changeset()
    socket = assign(socket, solved?: false, solution: solution, changeset: changeset)
    {:ok, socket, temporary_assigns: [guesses: initial_guesses]}
  end

  def handle_event("guess", %{"guess" => params}, socket) do
    solution = socket.assigns.solution

    case guess_changeset(params) do
      %Ecto.Changeset{valid?: true, changes: changes} ->
        year_d =
          case solution.year - changes.year do
            0 -> ""
            diff when diff > 0 -> "&uarr;"
            diff when diff < 0 -> "&darr;"
          end

        guess = %{
          id: Ecto.UUID.generate(),
          make: %{v: params["make"], s: changes.make == solution.make, d: nil},
          model: %{v: params["model"], s: changes.model == solution.model, d: nil},
          year: %{v: params["year"], s: changes.year == solution.year, d: year_d}
        }

        socket =
          socket
          |> update(:guesses, fn guesses -> [guess | guesses] end)
          |> assign(:changeset, guess_changeset())
          |> assign(:solved?, changes == solution)

        {:noreply, socket}

      changeset ->
        changeset = Map.put(changeset, :action, :update)
        {:noreply, socket |> assign(:changeset, changeset)}
    end
  end

  defp guess_changeset(attrs \\ %{}) do
    Game.Guess.new() |> Game.Guess.changeset(attrs)
  end

  def guess(assigns) do
    ~H"""
    <div id={@value.id} class="flex gap-x-2 mb-2">
      <.part w={44} value={@value.make} />
      <.part w={56} value={@value.model} />
      <.part w={32} value={@value.year} />
    </div>
    """
  end

  def part(assigns) do
    class = if assigns.value.s, do: "text-green-700 bg-green-50 ring-2 ring-green-500"

    ~H"""
    <div class={"w-#{@w} py-2 px-3 border border-transparent #{class}"}>
      <%= @value.v %>
      <%= if @value.d, do: raw @value.d %>
    </div>
    """
  end

  def text_input(assigns) do
    assigns = Map.put_new(assigns, :opts, [])

    ~H"""
    <%= text_input @form, @field, @opts %>
    """
  end

  def field(assigns) do
    %{form: form, field: field} = assigns
    errors = Keyword.get_values(form.errors, field)

    class = Map.get(assigns, :class, "")

    class =
      if errors != [] do
        class <> " errors"
      else
        class
      end

    ~H"""
    <div class={"#{class}"}><%= render_slot(@inner_block) %></div>
    """
  end
end
