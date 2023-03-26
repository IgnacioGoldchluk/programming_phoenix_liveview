defmodule PentoWeb.WrongLive do
  use PentoWeb, :live_view

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <h1>Your score: <%= @score %></h1>
    <h2>
      <%= @message %>
    </h2>
    <h2>
      <%= for n <- 1..10 do %>
        <.link href="#" phx-click="guess" phx-value-number={n}>
          <%= n %>
        </.link>
      <% end %>
    </h2>
    <h2>
      <%= if @won do %>
        <.link patch="#">Try again</.link>
      <% end %>
    </h2>
    """
  end

  defp initial_game_state(socket) do
    assign(socket,
      score: 0,
      message: "Make a guess:",
      correct: Enum.random(1..10) |> to_string,
      won: false
    )
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, initial_game_state(socket)}
  end

  def mount(_params, _session, socket) do
    {:ok, initial_game_state(socket)}
  end

  def handle_event("guess", %{"number" => guess} = values, socket) do
    correct_number = socket.assigns.correct

    case guess do
      ^correct_number -> handle_correct(values, socket)
      _ -> handle_incorrect(values, socket)
    end
  end

  defp handle_incorrect(%{"number" => guess}, socket) do
    message = "Your guess: #{guess}. Wrong. Guess again. "
    score = socket.assigns.score - 1

    {
      :noreply,
      assign(
        socket,
        message: message,
        score: score
      )
    }
  end

  defp handle_correct(%{"number" => guess}, socket) do
    message = "You won! The number was #{guess}"
    score = socket.assigns.score + 10

    {
      :noreply,
      assign(
        socket,
        message: message,
        score: score,
        won: true
      )
    }
  end
end
