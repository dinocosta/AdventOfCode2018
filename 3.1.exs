defmodule Claim do

  @typedoc """
  Claim representation
  """
  @type t :: %Claim{id: Integer.t, rows: Integer.t, columns: [Integer.t]}
  defstruct [:id, :rows, :columns]

  @claim_regex ~r/\A#(\d+)\ @\ (\d+),(\d+):\ (\d+)x(\d+)/

  @doc """
  Converts the claim's string representation into a Claim instance.

  ## Examples

    iex> Claim.from_string("#1 @ 1,3: 4x4")
    %Claim{id: 1, rows: [3, 4, 5, 6], columns: [1, 2, 3, 4]}

  """
  @spec from_string(String.t) :: Claim.t
  def from_string(string) do
    [[_, id, left, top, width, height]] = Regex.scan(@claim_regex, string)

    %Claim{
      id: String.to_integer(id),
      rows: Enum.to_list(String.to_integer(top)..String.to_integer(top) + String.to_integer(height) - 1),
      columns: Enum.to_list(String.to_integer(left)..String.to_integer(left) + String.to_integer(width) - 1)
    }
  end
end

defmodule Fabric do

  @typedoc """
  Fabric representation using nested lists.
  """
  @type t :: %{Integer.t => [Integer.t]}

  @spec update(Fabric.t, Claim.t) :: Fabric.t
  def update(fabric, claim), do: update_rows(fabric, claim.rows, claim)

  @spec update_rows(Fabric.t, List.t, Claim.t) :: Fabric.t
  def update_rows(fabric, [], _), do: fabric
  def update_rows(fabric, [row_index | row_indexes], claim) do
    row = Map.get(fabric, row_index)

    update_rows(Map.put(fabric, row_index, update_row(row, claim.columns, claim)), row_indexes, claim)
  end

  @spec update_row(List.t, List.t, Claim.t) :: List.t
  def update_row(row, [], _), do: row
  def update_row(row, [column_index | column_indexes], claim) do
    case Enum.at(row, column_index) == 0 do
      true -> update_row(List.replace_at(row, column_index, claim.id), column_indexes, claim)
      false -> update_row(List.replace_at(row, column_index, -1), column_indexes, claim)
    end
  end

  @spec to_string(Fabric.t) :: String.t()
  def to_string(fabric) when is_map(fabric),
    do: fabric |> Enum.map(fn({_, row}) -> row end)  |> Enum.map(&Fabric.to_string/1) |> Enum.join("\n")

  def to_string(row) when is_list(row), do: row |> Enum.map(&Fabric.to_string/1) |> Enum.join("")

  def to_string(0), do: "."
  def to_string(-1), do: "#"
  def to_string(number) when is_integer(number), do: Integer.to_string(number)
end

fabric = for index <- 0..1000, do: {index, List.duplicate(0, 1000)}, into: %{}
result =
  "3.input.txt"
  |> File.stream!()
  |> Enum.map(&Claim.from_string/1)
  |> Enum.reduce(fabric, fn(claim, fabric) -> Fabric.update(fabric, claim) end)
  |> Enum.reduce(0, fn({_, columns}, sum) -> sum + Enum.count(columns, fn(value) -> value == -1 end) end)

IO.puts result
