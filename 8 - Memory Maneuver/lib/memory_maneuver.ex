defmodule MemoryManeuver do
  @moduledoc """
  Documentation for MemoryManeuver.
  """

  @type tree_node :: {[tree_node], [Integer.t()]}

  @doc """
  Solves the first part of the problem.

  ## Examples

    iex> MemoryManeuver.part_one("2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2")
    138
  """
  @spec part_one(String.t()) :: Integer.t()
  def part_one(string) do
    {root, []} =
      string
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
      |> tree()

    checksum(root)
  end

  @doc """
  Solves the second part of the problem

  ## Examples

    iex> MemoryManeuver.part_two("2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2")
    66
  """
  @spec part_two(String.t()) :: Integer.t()
  def part_two(string) do
    {root, []} =
      string
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
      |> tree()

    root_value(root)
  end

  @doc """
  Given the tree representation creates the nodes.

  ## Examples

    iex> MemoryManeuver.tree([0, 3, 10, 11, 12])
    {{[], [10, 11, 12]}, []}
    iex> MemoryManeuver.tree([2, 1, 0, 1, 1, 1, 1, 0, 3, 1, 2, 3, 10, 9])
    {{[{[], [1]}, {[{[], [1, 2, 3]}], [10]}], [9]}, []}
  """
  @spec tree([Integer.t()]) :: node
  def tree([0 | [metadata | tail]]) do
    {entries, rest} =
      tail
      |> Enum.split(metadata)

    {{[], entries}, rest}
  end

  def tree([children | [metadata | tail]]) do
    {child_nodes, remaining} = children_nodes(children, tail)
    {entries, rest} = Enum.split(remaining, metadata)
    {{child_nodes, entries}, rest}
  end

  @doc """
  Recursively create the list of children nodes
  given the list of integers and the number of nodes
  to be generated.

  ## Examples

    iex> MemoryManeuver.children_nodes(2, [1, 1, 0, 2, 5, 4, 10, 0, 1, 23])
    {[{[{[], [5, 4]}], [10]}, {[], [23]}], []}
  """
  @spec children_nodes(Integer.t(), [Integer.t()], [node]) :: {node, [Integer.t()]}
  def children_nodes(number, list, nodes \\ [])

  def children_nodes(1, list, nodes) do
    {subtree, tail} = tree(list)

    {Enum.reverse([subtree | nodes]), tail}
  end

  def children_nodes(number, list, nodes) do
    {subtree, tail} = tree(list)
    children_nodes(number - 1, tail, [subtree | nodes])
  end

  @doc """
  Sums the metadata entries from the tree.

  ## Examples

    iex> MemoryManeuver.checksum({[{[], [10, 11, 12]}, {[{[], [99]}], [2]}], [1, 1, 2]})
    138
  """
  @spec checksum(node) :: Integer.t()
  def checksum({0, entries}), do: Enum.sum(entries)

  def checksum({children, entries}),
    do: Enum.sum(entries) + Enum.sum(Enum.map(children, &checksum/1))

  @doc """
  Calculates the root value of the given tree.

  ## Examples

    iex> MemoryManeuver.root_value({[{[], [10, 11, 12]}, {[{[], [99]}], [2]}], [1, 1, 2]})
    66
  """
  @spec root_value(node) :: Integer.t()
  def root_value({[], entries}), do: Enum.sum(entries)

  def root_value({children, entries}) do
    entries
    |> Enum.map(fn entry -> root_value(Enum.at(children, entry - 1, {0, []})) end)
    |> Enum.sum()
  end
end
