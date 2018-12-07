defmodule ChronalCoordinates do
  @moduledoc """
  Documentation for ChronalCoordinates.
  """

  import NimbleParsec

  defparsec :coordinate, integer(min: 1) |> ignore(string(", ")) |> integer(min: 1)

  @type coordinate :: {number, number}

  @doc """
  Solves part one.

  ## Examples

    iex> ChronalCoordinates.part_one([{1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9}])
    17
  """
  def part_one(coordinates) do
    {max_x, min_x, max_y, min_y} = boundaries(coordinates)

    bottom_boundary = for x <- min_x..max_x, do: {x, min_y}
    top_boundary = for x <- min_x..max_x, do: {x, max_y}
    left_boundary = for y <- min_y..max_y, do: {min_x, y}
    right_boundary = for y <- min_y..max_y, do: {max_x, y}

    invalid_coordinates =
      bottom_boundary ++ top_boundary ++ left_boundary ++ right_boundary
      |> List.flatten()
      |> Enum.map(fn(coordinate) -> closest(coordinates, coordinate) end)
      |> Enum.filter(fn(coordinates) -> length(coordinates) == 1 end)
      |> List.flatten()

    coordinates
    |> boundaries()
    |> grid_coordinates()
    |> Enum.map(fn(coordinate) -> closest(coordinates, coordinate) end)
    |> Enum.filter(fn(coordinates) -> length(coordinates) == 1 end)
    |> List.flatten()
    |> Enum.filter(fn(coordinate) -> coordinate not in invalid_coordinates end)
    |> Enum.reduce(%{}, fn(coordinate, map) -> Map.update(map, coordinate, 1, &(&1 + 1)) end)
    |> Enum.max_by(fn({_, count}) -> count end)
    |> elem(1)
  end

  @doc """
  Solves part two.

  ## Examples

    iex> ChronalCoordinates.part_two([{1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9}], 32)
    16
  """
  @spec part_two([coordinate]) :: Integer.t
  def part_two(coordinates, threshold \\ 10_000) do
    coordinates
    |> boundaries()
    |> grid_coordinates()
    |> Enum.map(fn(coordinate) -> Enum.sum(coordinates |> Enum.map(&(distance(&1, coordinate)))) end)
    |> Enum.filter(fn(sum) -> sum < threshold end)
    |> length()
  end


  @doc """
  Given a list of coordinates determines the edge coordinates.
  Returns a tuple where the order of the elements is:
  * Minimum X
  * Maximum X
  * Minimum Y
  * Maximum Y

  ## Examples

    iex> ChronalCoordinates.boundaries([{1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9}])
    {1, 8, 1, 9}
  """
  @spec boundaries([coordinate]) :: [coordinate]
  def boundaries(coordinates) do
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(coordinates, fn({x, _}) -> x end)
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(coordinates, fn({_, y}) -> y end)

    {min_x, max_x, min_y, max_y}
  end

  @doc """
  Returns the list of coordinates given the boundaries.

  ## Examples

    iex> ChronalCoordinates.grid_coordinates({1, 2, 1, 2})
    [{1, 1}, {1, 2}, {2, 1}, {2, 2}]
  """
  @spec grid_coordinates({number, number, number, number}) :: [coordinate]
  def grid_coordinates({min_x, max_x, min_y, max_y}),
    do: for x <- min_x..max_x, y <- min_y..max_y, do: {x, y}

  @doc """
  Given the list of coordinates and a coordidnate determines which one or ones
  are closes to it.

  ## Examples

    iex> ChronalCoordinates.closest([{1, 1}, {3, 4}, {4, 3}], {5, 5})
    [{3, 4}, {4, 3}]
  """
  @spec closest([coordinate], coordinate) :: [coordinate]
  def closest(coordinates, destination) do
    distances =
      coordinates
      |> Enum.map(fn(coordinate) -> {coordinate, distance(coordinate, destination)} end)

    {_, min_distance} =
      distances
      |> Enum.min_by(fn({_, distance}) -> distance end)

    distances
    |> Enum.filter(fn({_, distance}) -> distance == min_distance end)
    |> Enum.map(fn({coordinate, _}) -> coordinate end)
  end

  @doc """
  Determines the Manhattan distance between two
  coordinates.

  ## Examples

    iex> ChronalCoordinates.distance({1, 1}, {3, 4})
    5
  """
  @spec distance(coordinate, coordinate) :: number
  def distance({a, b}, {c, d}), do: Kernel.abs(a - c) + Kernel.abs(b - d)

  @doc """
  Parses a string into a coordinate.

  ## Examples

  iex> ChronalCoordinates.parse("123, 42")
  {123, 42}
  """
  @spec parse(String.t) :: coordinate
  def parse(string) do
    {:ok, [x, y], _, _, _, _} = ChronalCoordinates.coordinate(string)
    {x, y}
  end
end
