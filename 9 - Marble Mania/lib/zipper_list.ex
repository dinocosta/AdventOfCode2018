defmodule ZipperList do
  @moduledoc """
  Zipper implementation of a list.
  """

  @type t :: {List.t(), List.t()}

  @doc """
  Creates a new zipper list.

  ## Examples

    iex> ZipperList.new()
    {[], []}
  """
  @spec new() :: ZipperList.t()
  def new(), do: {[], []}

  @doc """
  Moves focus to next element of the list.

  ## Examples

    iex> ZipperList.next({[1, 2], [3, 4, 5, 6]})
    {[3, 1, 2], [4, 5, 6]}
    iex> ZipperList.next({[1, 2], [3]})
    {[], [2, 1, 3]}
  """
  @spec next(ZipperList.t()) :: ZipperList.t()
  def next({elements, [value]}), do: {[], Enum.reverse([value | elements])}
  def next({left, [value | right]}), do: {[value | left], right}

  @doc """
  Moves focus to preivous element of the list.

  ## Examples

    iex> ZipperList.previous({[2, 1], [3, 4, 5, 6]})
    {[1], [2, 3, 4, 5, 6]}
    iex> ZipperList.previous({[], [1, 2, 3, 4, 5, 6]})
    {[5, 4, 3, 2, 1], [6]}
  """
  @spec previous(ZipperList.t()) :: ZipperList.t()
  def previous({[], elements}) do
    [current | previous] = Enum.reverse(elements)

    {previous, [current]}
  end

  def previous({[value | left], right}), do: {left, [value | right]}

  @doc """
  Remove the current pointed value.

  ## Examples

    iex> ZipperList.pop({[2, 1], [3, 4, 5, 6]})
    {{[2, 1], [4, 5, 6]}, 3}
  """
  @spec pop(ZipperList.t()) :: {ZipperList.t(), any}
  def pop({left, [value | right]}), do: {{left, right}, value}

  @doc """
  Insert value in the current position

  ## Example

    iex> ZipperList.insert({[2, 1], [5, 4, 3]}, 6)
    {[2, 1], [6, 5, 4, 3]}
  """
  @spec insert(ZipperList.t(), any) :: ZipperList.t()
  def insert({left, right}, value), do: {left, [value | right]}
end
