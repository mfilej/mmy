defmodule RidleWeb.HomeLive do
  use RidleWeb, :live_view

  alias Ridle.Game

  def mount(_params, _session, socket) do
    changeset = guess_changeset()
    socket = assign(socket, :changeset, changeset)
    {:ok, socket, temporary_assigns: [guesses: []]}
  end

  def handle_event("guess", %{"guess" => params}, socket) do
    case guess_changeset(params) do
      %Ecto.Changeset{valid?: true} ->
        guess = %{id: Ecto.UUID.generate()}

        socket =
          socket
          |> update(:guesses, fn guesses -> [guess | guesses] end)
          |> assign(:changeset, guess_changeset())

        {:noreply, socket}

      changeset ->
        changeset = Map.put(changeset, :action, :update)
        {:noreply, socket |> assign(:changeset, changeset)}
    end
  end

  defp guess_changeset(attrs \\ %{}) do
    Game.Guess.new() |> Game.Guess.changeset(attrs)
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
