defmodule AlchemicalReduction do
  @moduledoc """
  Documentation for AlchemicalReduction.
  """

  @doc """
  Solves the first part of the problem.

  ## Examples

      iex> AlchemicalReduction.part_one("dabAcCaCBAcCcaDA")
      10
  """
  def part_one(string) do
    string
    |> String.codepoints()
    |> chemical_reduce()
    |> Enum.join()
    |> String.length()
  end

  def part_two(string) do
    ?a..?z
    |> Enum.map(fn(character) -> {character, string |> String.replace(to_letter(character), "") |> String.replace(to_letter(character - 32), "")} end)
    |> Enum.map(fn({character, polymer}) -> {character, AlchemicalReduction.part_one(polymer)} end)
    |> Map.new()
    |> Map.values()
    |> Enum.min()
  end

  @doc """

  ## Examples

  iex> AlchemicalReduction.chemical_reduce(
  ...> ["d", "a", "b", "A", "c", "C", "a", "C", "B", "A", "c", "C", "c", "a", "D", "A"])
  ["d", "a", "b", "C", "B", "A", "c", "a", "D", "A"]
  """
  @spec chemical_reduce(List.t, List.t) :: List.t
  def chemical_reduce(letters, accumulator \\ [])
  def chemical_reduce([], accumulator), do: Enum.reverse(accumulator)
  def chemical_reduce([letter | []], accumulator), do: Enum.reverse([letter | accumulator])
  def chemical_reduce([first | [second | letters]], []), do: chemical_reduce([second | letters], [first])

  def chemical_reduce([first | [second | letters]], accumulator = [head | tail]) do
    cond do
      Kernel.abs(to_char(first) - to_char(second)) == ?a - ?A ->
        chemical_reduce(letters, accumulator)
      Kernel.abs(to_char(first) - to_char(head)) == ?a - ?A ->
        chemical_reduce([second | letters], tail)
      true -> chemical_reduce([second | letters], [first | accumulator])
    end
  end

  @doc """
  Returns the caracther code for the given letter.

  ## Examples

      iex> AlchemicalReduction.to_char("a")
      97
  """
  @spec to_char(String.t) :: Integer.t
  def to_char(letter), do: Enum.at(String.to_charlist(letter), 0)

  @doc """
  Converts a given character into its letter representation.

  ## Examples

      iex> AlchemicalReduction.to_letter(97)
      "a"
  """
  @spec to_letter(Integer.t) :: String.t
  def to_letter(character), do: [character] |> List.to_string()
end
