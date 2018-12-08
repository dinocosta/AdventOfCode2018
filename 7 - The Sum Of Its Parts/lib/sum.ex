defmodule Sum do
  @moduledoc """
  Documentation for Sum.
  """

  import NimbleParsec

  defparsec :sequence,
    ignore(string("Step "))
    |> ascii_char([?A..?Z])
    |> ignore(string(" must be finished before step "))
    |> ascii_char([?A..?Z])

  @doc """
  Solves the first part of the problem.

  ## Examples

  iex> Sum.part_one("Step C must be finished before step A can begin.\\n
  ...>Step C must be finished before step F can begin.\\n
  ...>Step A must be finished before step B can begin.\\n
  ...>Step A must be finished before step D can begin.\\n
  ...>Step B must be finished before step E can begin.\\n
  ...>Step D must be finished before step E can begin.\\n
  ...>Step F must be finished before step E can begin.\\n")
  "CABDFE"
  """
  @spec part_one(String.t) :: String.t
  def part_one(input) do
    sequences =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&Sum.parse/1)

    dependency_map =
      sequences
      |> Enum.reduce(%{}, fn({dep, step}, map) -> Map.update(map, step, [dep], &([dep | &1])) end)

    steps =
      sequences
      |> Enum.reduce([], fn({dep, step}, steps) -> [dep | [step | steps]] end)
      |> Enum.uniq()

    Enum.join(sequence(steps, dependency_map))
  end

  @doc """
  Given the list of steps and the dependency map builds
  the sequence of events.
  """
  @spec sequence([String.t], %{String.t => String.t}) :: [String.t]
  def sequence([], _), do: []
  def sequence(steps, dependencies) do
    {[step], remaining_steps} = Enum.split_with(steps, &(&1 == next(steps, dependencies, steps)))
    [step | sequence(remaining_steps, dependencies)]
  end

  @doc """
  Given the list of steps and the dependency map and the
  list of steps left selects the next step to be done.

  ## Examples

    iex> Sum.next(["A", "B", "C"], %{"A" => ["C"], "B" => ["A"]}, ["A", "B", "C"])
    "C"
    iex> Sum.next(["A", "F", "B", "C"], %{"A" => ["C"], "B" => ["A"]}, ["A", "B", "C"])
    "C"
  """
  @spec next([String.t], {String.t, [String.t]}, [String.t]) :: String.t
  def next(steps, dependencies, remaining) do
    steps
    |> Enum.filter(fn(step) -> is_doable?(Map.get(dependencies, step, []), remaining) end)
    |> Enum.sort()
    |> Enum.at(0)
  end

  @doc """
  Determines wether a step can be done given the list
  of dependencies and the steps remaining.

  ## Examples

    iex> Sum.is_doable?([], ["D"])
    true
    iex> Sum.is_doable?(["B", "C"], ["D"])
    true
    iex> Sum.is_doable?(["B", "C"], ["C"])
    false
  """
  @spec is_doable?([String.t], [String.t]) :: boolean
  def is_doable?([], _), do: true
  def is_doable?(dependencies, steps) do
    case Enum.filter(dependencies, fn(dep) -> dep in steps end) do
      [] -> true
      _ -> false
    end
  end

  @doc """
  Parse a string into an event sequence.

  ## Example

    iex> Sum.parse("Step F must be finished before step E can begin.")
    {"F", "E"}
  """
  @spec parse(String.t) :: {String.t, String.t}
  def parse(string) do
    {:ok, [first, second], _, _, _, _} = Sum.sequence(string)
    {List.to_string([first]), List.to_string([second])}
  end
end
