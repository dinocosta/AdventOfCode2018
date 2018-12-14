defmodule Star do
  @moduledoc """
  Represents and allows manipulations of stars.
  """

  defstruct [:x, :y, :velocity_x, :velocity_y]

  @type t :: %{x: Integer.t(), y: Integer.t(), velocity_x: Integer.t(), velocity_y: Integer.t()}

  @doc """
  Create a Star instance given a list.

  ## Examples

    iex> Star.from_list(["1", "2", "3", "4"])
    %Star{x: 1, y: 2, velocity_x: 3, velocity_y: 4}
  """
  @spec from_list([Integer.t()]) :: Star.t()
  def from_list([x, y, velocity_x, velocity_y]) do
    %Star{
      x: String.to_integer(x),
      y: String.to_integer(y),
      velocity_x: String.to_integer(velocity_x),
      velocity_y: String.to_integer(velocity_y)
    }
  end

  @doc """
  Moves a star according to its current position and velocity.

  ## Examples

    iex> Star.move(%Star{x: 1, y: 0, velocity_x: 2, velocity_y: 2})
    %Star{x: 3, y: 2, velocity_x: 2, velocity_y: 2}
  """
  @spec move(Star.t()) :: Star.t()
  def move(%{x: x, y: y, velocity_x: velocity_x, velocity_y: velocity_y} = star),
    do: %Star{star | x: x + velocity_x, y: y + velocity_y}
end
