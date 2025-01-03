defmodule RidleWeb.HomeLive do
  use RidleWeb, :live_view

  alias Ridle.Game

  @rounds 5

  def mount(_params, _session, socket) do
    rounds = Game.list_round_numbers()

    {:ok, socket |> assign(:rounds, rounds)}
  end

  def handle_params(%{"id" => id}, _uri, socket), do: init(socket, id)
  def handle_params(_params, _uri, socket), do: init(socket, "1")

  defp init(socket, id) do
    round = Game.find_round(id)
    changeset = Game.change_guess_attempt(%{})

    {:noreply,
     socket
     |> stream(:outcomes, [], reset: true)
     |> assign(:round, round)
     |> assign(:progress, {1, false, false, false})
     |> assign_form(changeset)}
  end

  def handle_event("guess", _, %{assigns: %{progress: {attempts, _, _, _}}} = socket)
      when attempts > @rounds,
      do: {:noreply, socket}

  def handle_event("guess", %{"guess_attempt" => params}, socket) do
    %{round: round, progress: {attempt, _, _, _}} = socket.assigns

    case Game.offer_guess(round, attempt, params) do
      {:ok, outcome} ->
        {:noreply,
         socket
         |> stream_insert(:outcomes, outcome, at: 0)
         |> assign(
           :progress,
           {attempt + 1, outcome.make.correct?, outcome.model.correct?, outcome.year.correct?}
         )
         |> push_event("refocus", %{})}

      {:error, changeset} ->
        {:noreply, socket |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"guess_attempt" => params}, socket) do
    changeset = Game.change_guess_attempt(params)
    {:noreply, socket |> assign_form(changeset)}
  end

  defp assign_form(socket, changeset) do
    form = to_form(changeset)
    socket |> assign(:form, form)
  end

  attr :id, :string, required: true
  attr :outcome, Game.GuessOutcome, required: true

  defp guess(assigns) do
    ~H"""
    <div id={@id} class="mb-2 flex gap-x-2">
      <.part field={@outcome.make} w="w-5/12" />
      <.part field={@outcome.model} w="w-5/12" />
      <.part field={@outcome.year} w="w-2/12" right />
    </div>
    """
  end

  attr :field, Game.GuessOutcome.Field, required: true
  attr :w, :string, required: true
  attr :right, :boolean, default: false

  defp part(assigns) do
    ~H"""
    <div
      data-correct={@field.correct? && "true"}
      class={[
        @w,
        @right && "text-right",
        "flex items-center justify-between px-3 py-2",
        "bg-rose-100 text-rose-800",
        "data-correct:bg-emerald-100 data-correct:text-emerald-800"
      ]}
    >
      <span><%= @field.value %></span>
      <span><%= hint(@field.hint) %></span>
      <%= if @field.correct? do %>
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

  defp hint(:gt), do: raw("&uarr;")
  defp hint(:lt), do: raw("&darr;")
  defp hint(nil), do: ""

  attr :form, Phoenix.HTML.Form, required: true
  attr :field, :atom, required: true
  attr :correct, :boolean, default: false
  attr :failed, :boolean, default: false
  attr :disabled, :boolean
  attr :w, :string, required: true
  attr :type, :string, default: "text"
  attr :rest, :global

  defp field(assigns) do
    ~H"""
    <div
      data-correct={@correct && "true"}
      data-failed={@failed && "true"}
      class={[
        "#{@w} ring-2 ring-gray-400 ring-offset-1",
        "focus-within:ring-gray-600",
        "[&_input[type=number]]:text-right placeholder:[&_input[type=number]]:text-left",
        "data-correct:ring-emerald-500 focus-within:data-correct:ring-emerald-500"
      ]}
    >
      <.input
        type={@type}
        field={@form[@field]}
        disabled={@correct || @failed}
        phx-debounce="100"
        autocomplete="off"
        {@rest}
      />
      <input
        :if={@correct}
        type="hidden"
        name={Phoenix.HTML.Form.input_name(@form, @field)}
        value={Phoenix.HTML.Form.input_value(@form, @field)}
      />
    </div>
    """
  end

  defp solved?({_, true, true, true}), do: true
  defp solved?({_, _, _, _}), do: false

  defp game_over?({round, _, _, _}) when round > @rounds, do: true
  defp game_over?({_, _, _, _}), do: false

  defp data_game_value(progress) do
    cond do
      solved?(progress) -> "solved"
      game_over?(progress) -> "over"
      true -> "playing"
    end
  end
end
