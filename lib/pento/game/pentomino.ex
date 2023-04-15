defmodule Pento.Game.Pentomino do
  @default_location {8, 8}

  alias Pento.Game.{Point, Shape}

  defstruct name: :i,
            rotation: 0,
            reflected: false,
            location: @default_location

  def new(fields \\ []), do: __struct__(fields)

  def rotate(%{rotation: degrees} = p) do
    %{p | rotation: rem(degrees + 90, 360)}
  end

  def flip(%{reflected: reflection} = p) do
    %{p | reflected: not reflection}
  end

  def up(p), do: %{p | location: Point.move(p.location, {0, -1})}
  def down(p), do: %{p | location: Point.move(p.location, {0, 1})}
  def left(p), do: %{p | location: Point.move(p.location, {-1, 0})}
  def right(p), do: %{p | location: Point.move(p.location, {1, 0})}

  def to_shape(pento) do
    Shape.new(pento.name, pento.rotation, pento.reflected, pento.location)
  end

  def overlapping?(pento1, pento2) do
    {p1, p2} = {to_shape(pento1).points, to_shape(pento2).points}
    Enum.count(p1 -- p2) != 5
  end
end
