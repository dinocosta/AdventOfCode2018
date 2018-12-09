defmodule Game do
  @moduledoc """
  Representation of a Marble Mania Game.
  """

  defstruct marbles: ZipperList.new() |> ZipperList.insert(0), players: %{}

  @type t :: %{
    marbles: ZipperList.t(),
    players: %{Integer.t() => Integer.t()}
  }
end

defmodule MarbleMania do
  @moduledoc """
  Documentation for MarbleMania.
  The ninth day of the Advent of Code 2018
  """

  @doc """
  Solves part one.

  ## Examples:

    iex> MarbleMania.part_one(9, 25)
    32
    iex> MarbleMania.part_one(10, 1618)
    8317
    iex> MarbleMania.part_one(13, 7999)
    146373
    iex> MarbleMania.part_one(17, 1104)
    2764
    iex> MarbleMania.part_one(21, 6111)
    54718
    iex> MarbleMania.part_one(30, 5807)
    37305
  """
  @spec part_one(Integer.t(), Integer.t()) :: Integer.t()
  def part_one(players, marbles)
  def part_one(players, marbles) do
    1..players
    |> Stream.cycle()
    |> Enum.take(marbles)
    |> Enum.with_index(1)
    |> Enum.reduce(%Game{}, fn({player, marble}, game) -> play(game, player, marble) end)
    |> Map.get(:players)
    |> Enum.max_by(fn({_, score}) -> score end)
    |> elem(1)
  end

  @doc """
  Solves part two

  ## Examples

    iex> MarbleMania.part_two(9, 25)
    22563
  """
  @spec part_two(Integer.t(), Integer.t()) :: Integer.t()
  def part_two(players, marbles), do: part_one(players, marbles * 100)

  @doc """
  Updates the list of marbles.

  ## Examples

    iex> MarbleMania.play(%Game{marbles: {[], [2, 1, 0]}, players: %{}}, 3, 3)
    %Game{marbles: {[1, 2], [3, 0]}, players: %{}}

    iex> MarbleMania.play(%Game{
    ...> marbles: {[5, 21, 10, 20, 2, 19, 9, 18, 4, 17, 8, 16, 0], [22, 11, 1, 12, 6, 13, 3, 14, 7, 15]},
    ...> players: %{}}, 5, 23)
    %Game{
      marbles: {[18, 4, 17, 8, 16, 0], [19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15]},
      players: %{5 => 32},
    }
  """
  @spec play(Game.t(), Integer.t(), Integer.t()) :: Game.t()
  def play(game, player, marble) when rem(marble, 23) == 0 do
    {marbles, value} =
      1..7
      |> Enum.reduce(game.marbles, fn(_, marbles) -> ZipperList.previous(marbles) end)
      |> ZipperList.pop()

    game
    |> Map.put(:marbles, marbles)
    |> Map.put(:players, Map.update(game.players, player, value + marble, &(&1 + value + marble)))
  end

  def play(game, _, marble) do
    marbles =
      game.marbles
      |> ZipperList.next()
      |> ZipperList.next()
      |> ZipperList.insert(marble)

    game
    |> Map.put(:marbles, marbles)
  end
end
