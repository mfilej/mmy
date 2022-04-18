defmodule RidleWeb.HomeLive do
  use RidleWeb, :live_view

  alias Ridle.Game

  def mount(_params, _session, socket) do
    initial_guesses = []

    # initial_guesses = [
    #   %{
    #     id: "cec590b2-9cd5-4ba7-85e4-c7a50262390f",
    #     make: %{v: "Aston Martin", s: true, d: nil},
    #     model: %{v: "DBS", s: false, d: nil},
    #     year: %{v: "2008", s: false, d: ""}
    #   },
    #   %{
    #     id: "cec590b2-9cd5-4ba7-85e4-c7a50262390e",
    #     make: %{v: "Ferrari", s: true, d: nil},
    #     model: %{v: "Testa Rossa", s: true, d: nil},
    #     year: %{v: "1978", s: false, d: ""}
    #   }
    # ]

    round = Game.current_round(DateTime.utc_now())

    changeset = guess_changeset()

    socket = assign(socket, round: round, solved?: false, changeset: changeset)

    {:ok, socket, temporary_assigns: [guesses: initial_guesses]}
  end

  def handle_event("guess", %{"guess" => params}, socket) do
    round = socket.assigns.round

    case guess_changeset(params) do
      %Ecto.Changeset{valid?: true, changes: changes} ->
        year_d =
          case round.year - changes.year do
            0 -> ""
            diff when diff > 0 -> "&uarr;"
            diff when diff < 0 -> "&darr;"
          end

        guess = %{
          id: Ecto.UUID.generate(),
          make: %{v: changes.make, s: changes.make == round.make, d: nil},
          model: %{v: changes.model, s: changes.model == round.model, d: nil},
          year: %{v: changes.year, s: changes.year == round.year, d: year_d}
        }

        socket =
          socket
          |> update(:guesses, fn guesses -> [guess | guesses] end)
          |> assign(:changeset, guess_changeset())
          |> assign(:solved?, changes == solution(round))

        {:noreply, socket}

      changeset ->
        changeset = Map.put(changeset, :action, :update)
        {:noreply, socket |> assign(:changeset, changeset)}
    end
  end

  defp guess_changeset(attrs \\ %{}) do
    Game.Guess.new() |> Game.Guess.changeset(attrs)
  end

  defp guess(assigns) do
    ~H"""
    <div id={@value.id} class="flex gap-x-2 mb-2">
      <.part value={@value.make} class="w-5/12" />
      <.part value={@value.model} class="w-5/12" />
      <.part value={@value.year} class="w-2/12 text-right" />
    </div>
    """
  end

  def part(assigns) do
    class =
      if assigns.value.s do
        "bg-green-100 text-green-800"
      else
        "bg-zinc-100 text-zinc-800"
      end

    ~H"""
    <div class={"#{@class} flex justify-between items-center py-2 px-3 #{class}"}>
      <span><%= @value.v %></span>
      <span><%= if @value.d, do: raw(@value.d) %></span>
      <%= if @value.s do %>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-5 w-5"
          viewBox="0 0 20 20"
          fill="currentColor"
        >
          <path
            fill-rule="evenodd"
            d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
            clip-rule="evenodd"
          />
        </svg>
      <% end %>
    </div>
    """
  end

  def text_input(assigns) do
    assigns = Map.put_new(assigns, :opts, [])

    ~H"""
    <%= text_input(@form, @field, @opts) %>
    """
  end

  def field(assigns) do
    %{form: form, field: field} = assigns
    errors = Keyword.get_values(form.errors, field)

    assigns =
      assigns
      |> Map.put_new(:placeholder, nil)
      |> Map.put_new(:type, "text")
      |> Map.put_new(:min, nil)
      |> Map.put_new(:max, nil)

    error_class =
      if errors != [] do
        "error bg-rose-100 ring-rose-300 focus:bg-rose-50"
      else
        "bg-zinc-50 ring-zinc-400 focus:bg-white"
      end

    ~H"""
    <%= text_input(form, field,
      placeholder: @placeholder,
      type: @type,
      min: @min,
      max: @max,
      autocomplete: "off",
      class: ~s"
        #{@w}
        py-2 px-3 border-0 text-zinc-800 ring-2 ring-inset
        focus:ring-2 focus:ring-zinc-600
        #{error_class}"
    ) %>
    """
  end

  defp solution(%Game.Round{make: make, model: model, year: year}) do
    %{make: make, model: model, year: year}
  end
end
