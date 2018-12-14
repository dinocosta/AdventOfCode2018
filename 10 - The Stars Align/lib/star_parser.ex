defmodule StarParser do
  @moduledoc """
  Provides functionality to parse a string into
  a star.
  """

  @star_regex ~r/position=<(?<x>-?\d+),(?<y>-?\d+)>velocity=<(?<vx>-?\d+),(?<vy>-?\d+)>/
  import NimbleParsec

  defparsec(
    :star_parser,
    ignore(string("position=<"))
    |> integer(min: 1)
    |> ignore(string(","))
    |> integer(min: 1)
    |> ignore(string(">velocity=<"))
    |> integer(min: 1)
    |> ignore(string(","))
    |> integer(min: 1)
  )

  @doc """
  Parses a string and returns a star.

  ## Examples

    iex> StarParser.parse("position=< 9,  1> velocity=< 0,  2>")
    {{9, 1}, {0, 2}}
  """
  @spec parse(String.t()) :: Stars.t()
  def parse(input) do
    %{"vx" => vx, "vy" => vy, "x" => x, "y" => y} =
      @star_regex
      |> Regex.named_captures(String.replace(input, " ", ""))

    {{String.to_integer(x), String.to_integer(y)}, {String.to_integer(vx), String.to_integer(vy)}}
  end
end
