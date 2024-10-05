defmodule RidleWeb.HomeLive do
  use RidleWeb, :live_view

  alias Ridle.Game

  def mount(_params, _session, socket) do
    rounds = Game.list_round_numbers()

    {:ok,
     socket
     |> assign(:rounds, rounds)
     |> stream_configure(:guesses, dom_id: &"guess-#{Map.get(&1, "id")}")}
  end

  def handle_params(%{"id" => id}, _uri, socket), do: init(socket, id)
  def handle_params(_params, _uri, socket), do: init(socket, "1")

  defp init(socket, id) do
    round = Game.find_round(id)
    form = to_form(Game.change_guess(%{}))

    {:noreply,
     socket |> stream(:guesses, [], reset: true) |> assign(:form, form) |> assign(:round, round)}
  end

  def handle_event("guess", %{"guess" => params}, socket) do
    round = socket.assigns.round

    form = to_form(%Game.Guess{} |> Game.change_guess(params))

    {:noreply, socket |> assign(:form, form)}
  end

  defp guess(assigns) do
    ~H"""
    <div id={@id} class="mb-2 flex gap-x-2">
      <.part value={@value["make"]} class="w-5/12" />
      <.part value={@value["model"]} class="w-5/12" />
      <.part value={@value["year"]} class="w-2/12 text-right" />
    </div>
    """
  end

  def part(assigns) do
    class =
      if assigns.value["s"] do
        ~k"bg-green-100 text-green-800"
      else
        ~k"bg-rose-50 text-rose-900"
      end
      |> dbg()

    assigns = assign(assigns, class: class)

    ~H"""
    <div class={"#{@class} #{@class} flex items-center justify-between px-3 py-2"}>
      <span><%= @value["v"] %></span>
      <span><%= if d = @value["d"], do: raw(d) %></span>
      <%= if @value["s"] do %>
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

  attr :form, :map, required: true
  attr :field, :atom, required: true
  attr :class, :string, default: nil
  attr :rest, :global

  def field(assigns) do
    ~H"""
    <.input type="text" field={@form[@field]} autocomplete="off" class={@class} {@rest} />
    """
  end

  defp sigil_k(string, []) do
    string
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end
end
