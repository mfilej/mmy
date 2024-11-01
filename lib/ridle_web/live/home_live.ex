defmodule RidleWeb.HomeLive do
  use RidleWeb, :live_view

  alias Ridle.Game

  def mount(_params, _session, socket) do
    rounds = Game.list_round_numbers()

    {:ok,
     socket
     |> assign(:rounds, rounds)
     |> assign(:attempt, 1)}
  end

  def handle_params(%{"id" => id}, _uri, socket), do: init(socket, id)
  def handle_params(_params, _uri, socket), do: init(socket, "1")

  defp init(socket, id) do
    round = Game.find_round(id)

    {:noreply,
     socket
     |> stream(:guesses, [], reset: true)
     |> assign(:round, round)
     |> assign_form()}
  end

  def handle_event("guess", %{"guess" => params}, socket) do
    %{round: round, attempt: attempt} = socket.assigns

    guess =
      Game.offer_guess(params)
      |> Ecto.Changeset.apply_action(:validate)
      |> dbg()

    case guess do
      {:ok, guess} ->
        {:noreply,
         socket
         |> stream_insert(:guesses, guess)
         |> assign_form()}

      {:error, changeset} ->
        {:noreply, socket |> assign_form(changeset)}
    end
  end

  defp assign_form(socket, changeset \\ nil) do
    changeset = changeset || Game.offer_guess(%{})
    form = to_form(changeset, id: "guess-#{socket.assigns.attempt}")
    socket |> assign(:form, form)
  end

  defp guess(assigns) do
    ~H"""
    <div id={@id} class="mb-2 flex gap-x-2">
      <.part value={@value.make} class="w-5/12" />
      <.part value={@value.model} class="w-5/12" />
      <.part value={@value.year} class="w-2/12 text-right" />
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

  attr :field, :any, required: true
  attr :class, :string, default: nil
  attr :rest, :global

  def field(assigns) do
    ~H"""
    <.input type="text" field={@field} autocomplete="off" class={@class} {@rest} />
    """
  end

  defp sigil_k(string, []) do
    string
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end
end
