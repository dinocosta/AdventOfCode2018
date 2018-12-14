defmodule Stars do
  @moduledoc """
  Documentation for Stars.
  """

  @star_regex ~r/\Aposition=<\s*(-?\d+),\s*(-?\d+)>\s*velocity=<\s*(-?\d+),\s*(-?\d+)>\z/

  @spec part_one([Star.t()]) :: [Star.t()]
  def part_one(stars) do
    bounding_box      = bounding_box(stars)
    new_stars         = Enum.map(stars, &Star.move/1)
    new_bounding_box  = bounding_box(new_stars)

    case expanding?(new_bounding_box, bounding_box) do
      true -> IO.puts(sky(stars))
      false -> part_one(new_stars)
    end
  end

  @spec part_two([Star.t()]) :: Integer.t()
  def part_two(stars, seconds \\ 0) do
    bounding_box      = bounding_box(stars)
    new_stars         = Enum.map(stars, &Star.move/1)
    new_bounding_box  = bounding_box(new_stars)

    case expanding?(new_bounding_box, bounding_box) do
      true -> seconds
      false -> part_two(new_stars, seconds + 1)
    end
  end

  @doc """
  Parses strings into list of Star instances.

  ## Examples

  iex> Stars.parse("position=< 9,  1> velocity=< 0,  2>\\n")
  [%Star{x: 9, y: 1, velocity_x: 0, velocity_y: 2}]
  """
  @spec parse(String.t()) :: [Star.t()]
  def parse(lines) do
    lines
    |> String.split("\n", trim: true)
    |> Enum.map(fn(line) -> Regex.run(@star_regex, line, capture: :all_but_first) end)
    |> Enum.map(fn(list) -> Star.from_list(list) end)
  end

  @doc """
  Calculates the bounding box for the given list of stars.

  ## Examples

  iex> Stars.bounding_box([
  ...> %Star{x: 0, y: 0, velocity_x: 1, velocity_y: 2},
  ...> %Star{x: 2, y: -2, velocity_x: 1, velocity_y: 2},
  ...> ])
  {0..2, -2..0}
  """
  @spec bounding_box([Star.t()]) :: {Range.t(), Range.t()}
  def bounding_box(stars) do
    {min_x, max_x} = stars |> Enum.map(fn(star) -> Map.get(star, :x) end) |> Enum.min_max()
    {min_y, max_y} = stars |> Enum.map(fn(star) -> Map.get(star, :y) end) |> Enum.min_max()

    {min_x..max_x, min_y..max_y}
  end

  @spec sky([Star.t()]) :: String.t()
  def sky(stars) do
    coordinates_map = Enum.group_by(stars, fn(%{x: x, y: y}) -> {x, y} end)
    {min_x..max_x, min_y..max_y} = bounding_box(stars)

    max_y..min_y
    |> Enum.reduce([], fn(y, list) -> [row(coordinates_map, y, min_x..max_x) | list] end)
    |> Enum.join("\n")
  end

  @spec row(Map.t(), Integer.t(), Range.t()) :: String.t()
  def row(coordinates_map, y, min_x..max_x) do
    min_x..max_x
    |> Enum.reduce("", fn(x, string) -> string <> star_character(Map.get(coordinates_map, {x, y})) end)
  end

  @spec star_character(List.t()) :: String.t()
  defp star_character(nil), do: "."
  defp star_character(_), do: "#"

  @doc """

  ## Examples

    iex> Stars.expanding?({0..2, 0..2}, {0..1, 0..1})
    true
    iex> Stars.expanding?({0..1, 0..1}, {0..2, 0..2})
    false
  """
  @spec expanding?({Range.t(), Range.t()}, {Range.t(), Range.t()}) :: boolean()
  def expanding?({x_1..x_2, y_1..y_2}, {x_3..x_4, y_3..y_4}) do
    area_a = Kernel.abs(x_2 - x_1) * Kernel.abs(y_2 - y_1)
    area_b = Kernel.abs(x_4 - x_3) * Kernel.abs(y_4 - y_3)

    area_a > area_b
  end
  def expanding?(_, nil), do: false
end
