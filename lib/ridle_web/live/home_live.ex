defmodule RidleWeb.HomeLive do
  use RidleWeb, :live_view

  require Logger

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

    {guesses, solved?} = {[], false}
    changeset = guess_changeset()

    {:noreply,
     socket
     |> assign(round: round, solved?: solved?, changeset: changeset)
     |> stream(:guesses, guesses, reset: true)}
  end

  def handle_event("guess", %{"guess" => params}, socket) do
    round = socket.assigns.round

    case guess_changeset(params) do
      %Ecto.Changeset{valid?: true, changes: changes} ->
        year_d =
          cond do
            changes.year > round.year_end ->
              "&darr;"

            changes.year < round.year_start ->
              "&uarr;"

            true ->
              ""
          end

        guess =
          %{
            "id" => Ecto.UUID.generate(),
            "make" => %{
              "v" => changes.make,
              "s" => part_solved?(changes.make, round.make),
              "d" => nil
            },
            "model" => %{
              "v" => changes.model,
              "s" => part_solved?(changes.model, round.model),
              "d" => nil
            },
            "year" => %{"v" => changes.year, "s" => year_solved?(round, changes), "d" => year_d}
          }

        solved? = solved?(round, changes)

        socket =
          socket
          |> stream_insert(:guesses, guess)
          |> assign(:changeset, guess_changeset())
          |> assign(:solved?, solved?)
          |> push_event("refocus", %{})

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

  def text_input(assigns) do
    assigns = Map.put_new(assigns, :opts, [])

    ~H"""
    <%= text_input(@form, @field, @opts) %>
    """
  end

  def field(assigns) do
    %{form: form, field: field} = assigns
    errors = Keyword.get_values(form.errors, field)

    error_class =
      if errors != [] do
        ~k"""
        error bg-rose-100 ring-rose-300
        placeholder:text-rose-400
        focus:bg-white focus:ring-rose-800
        placeholder:focus:text-zinc-500
        """
      else
        ~k"bg-zinc-50 ring-zinc-400 focus:bg-white"
      end

    assigns =
      assign(assigns,
        placeholder: nil,
        type: "text",
        min: nil,
        max: nil,
        form: form,
        field: field,
        error_class: error_class
      )

    ~H"""
    <%= text_input(@form, @field,
      placeholder: @placeholder,
      type: @type,
      min: @min,
      max: @max,
      autocomplete: "off",
      class: ~k"
        #{@w}
        py-2 px-3 border-0 text-zinc-800 ring-2 ring-inset
        focus:ring-2 focus:ring-zinc-600
        #{@error_class}"
    ) %>
    """
  end

  defp solved?(%Game.Round{} = round, changes) do
    part_solved?(changes.make, round.make) &&
      part_solved?(changes.model, round.model) &&
      year_solved?(round, changes)
  end

  defp part_solved?(guess, solution) do
    String.starts_with?(guess, solution)
  end

  defp year_solved?(%Game.Round{year_start: year_start, year_end: year_end}, %{year: year}),
    do: year in year_start..year_end

  defp sigil_k(string, []) do
    string
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end
end
