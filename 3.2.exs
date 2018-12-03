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

  @spec update(Fabric.t, Claim.t, MapSet.t) :: {Fabric.t, MapSet.t}
  def update(fabric, claim, ids) do
    {fabric, removed_ids} = update_rows(fabric, claim.rows, claim, [])

    # Checking if it's equal is not enough because if the current claim
    # touches an already conflicting space it means the IDs are already not
    # on the list of ids, therefore we need to check if there are any -1
    # values on the fabric space for the claim.
    case length(removed_ids) == 0 do
      true -> {fabric, MapSet.put(ids, claim.id)}
      false -> {fabric, removed_ids |> Enum.reduce(ids, fn(removed_id, ids) -> MapSet.delete(ids, removed_id) end)}
    end
  end

  @doc """
  Updates the list of rows of the fabric according to the provided claims.
  """
  @spec update_rows(Fabric.t, List.t, Claim.t, List.t) :: {Fabric.t, List.t}
  def update_rows(fabric, [], _, ids), do: {fabric, ids}
  def update_rows(fabric, [row_index | row_indexes], claim, ids) do
    row = Map.get(fabric, row_index)
    {updated_row, updated_ids} = update_row(row, claim.columns, claim, ids)

    update_rows(Map.put(fabric, row_index, updated_row), row_indexes, claim, updated_ids)
  end

  @doc """
  Updates a given row according to the provided claim.
  """
  @spec update_row(List.t, List.t, Claim.t, List.t) :: {List.t, List.t}
  def update_row(row, [], _, ids), do: {row, ids}
  def update_row(row, [column_index | column_indexes], claim, ids) do
    claiming_id = Enum.at(row, column_index)

    case claiming_id == 0 do
      true -> update_row(List.replace_at(row, column_index, claim.id), column_indexes, claim, ids)
      false -> update_row(List.replace_at(row, column_index, -1), column_indexes, claim, [claiming_id | ids])
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
{_, ids} =
  "3.input.txt"
  |> File.stream!()
  |> Enum.map(&Claim.from_string/1)
  |> Enum.reduce({fabric, MapSet.new()}, fn(claim, {fabric, ids}) -> Fabric.update(fabric, claim, ids) end)

IO.puts Enum.at(Enum.to_list(ids), 0)
