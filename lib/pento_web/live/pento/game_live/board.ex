defmodule PentoWeb.GameLive.Board do
  use PentoWeb, :live_component

  alias Pento.Game.Board
  alias Pento.Game
  import PentoWeb.GameLive.{Colors, Component}

  def render(assigns) do
    ~H"""
    <div id={@id} phx-window-keydown="key" phx-target={@myself}>
      <.canvas view_box="0 0 200 140">
        <%= for shape <- @shapes do %>
          <.shape
            points={shape.points}
            fill={color(shape.color, Board.active?(@board, shape.name), false)}
            name={shape.name}
          />
        <% end %>
      </.canvas>
      <hr />
      <.palette
        shape_names={@board.palette}
        completed_shape_names={Enum.map(@board.completed_pentos, & &1.name)}
      />
    </div>
    """
  end

  def update(%{puzzle: puzzle, id: id}, socket) do
    {
      :ok,
      socket
      |> assign_params(id, puzzle)
      |> assign_board()
      |> assign_shapes()
    }
  end

  def handle_event("pick", %{"name" => name}, socket) do
    {:noreply, socket |> pick(name) |> assign_shapes()}
  end

  def handle_event("key", %{"key" => key}, socket) do
    {:noreply, socket |> do_key(key) |> assign_shapes}
  end

  def assign_params(socket, id, puzzle) do
    assign(socket, id: id, puzzle: puzzle)
  end

  def assign_board(%{assigns: %{puzzle: puzzle}} = socket) do
    board =
      puzzle
      |> String.to_existing_atom()
      |> Board.new()

    assign(socket, board: board)
  end

  def assign_shapes(%{assigns: %{board: board}} = socket) do
    shape = Board.to_shape(board)
    assign(socket, shapes: [shape])
  end

  def do_key(socket, key) do
    case key do
      " " -> drop(socket)
      "ArrowLeft" -> move(socket, :left)
      "ArrowRight" -> move(socket, :right)
      "ArrowUp" -> move(socket, :up)
      "ArrowDown" -> move(socket, :down)
      "Shift" -> move(socket, :rotate)
      "Enter" -> move(socket, :flip)
      "Space" -> drop(socket)
      _ -> socket
    end
  end

  def move(%{assigns: %{board: board}} = socket, move) do
    case Game.maybe_move(board, move) do
      {:error, message} -> put_flash(socket, :info, message)
      {:ok, new_board} -> socket |> assign(board: new_board) |> assign_shapes()
    end
  end

  defp drop(%{assigns: %{board: board}} = socket) do
    case Game.maybe_drop(board) do
      {:error, message} -> put_flash(socket, :info, message)
      {:ok, new_board} -> socket |> assign(board: new_board) |> assign_shapes()
    end
  end

  defp pick(socket, name) do
    shape_name = String.to_existing_atom(name)
    update(socket, :board, &Board.pick(&1, shape_name))
  end
end
