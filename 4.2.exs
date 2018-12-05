defmodule Registry do
  defstruct guard: nil, timestamps: %{}

  @type t :: %{guard: Integer.t, timestamps: Map.t}

  @spec update(Registry.t, String.t) :: Registry.t
  def update(registry, string), do: string |> parse_event() |> update_with_event(registry)

  @spec parse_event(String.t) :: {atom, Integer.t}
  def parse_event(string) do
    case string =~ "shift" do
      true -> Regex.named_captures(~r/#(?<guard>\d+)/, string)
      false -> Regex.named_captures(~r/:(?<minutes>\d+)]/, string)
    end
  end

  @spec update_with_event(Map.t, Registry.t) :: Registry.t
  def update_with_event(%{"guard" => guard_id}, registry),
    do: Map.put(registry, :guard, String.to_integer(guard_id))

  def update_with_event(%{"minutes" => minutes}, registry) do
    minutes     = String.to_integer(minutes)
    timestamps  =
      registry.timestamps
      |> Map.update(registry.guard, [minutes], fn(list) -> list ++ [minutes] end)

    Map.put(registry, :timestamps, timestamps)
  end
end

defmodule ReposeRecord do
  @doc """
  Convert a list of start and stop minute timestamps to the list
  of minutes between.
  """
  @spec full_minutes(List.t) :: List.t
  def full_minutes(intervals) do
    intervals
    |> Enum.chunk_every(2)
    |> Enum.map(fn([start, stop]) -> Enum.to_list(start..stop - 1) end)
    |> List.flatten()
  end

  def map_max(map), do: map |> Enum.max_by(fn({guard, count}) -> count end)

  def minute_max({minute, guards}) do
    case length(Map.keys(guards)) == 0 do
      true -> {minute, {0, 0}}
      false -> {minute, Enum.max_by(guards, fn({_, count}) -> count end)}
    end
  end
end

registry =
  "4.input.txt"
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.sort()
  |> Enum.reduce(%{guard: nil, timestamps: %{}}, fn(string, registry) -> Registry.update(registry, string) end)

minutes = 0..59 |> Enum.reduce(%{}, fn(minute, map) -> Map.put(map, minute, %{}) end)

{minute, {guard, _}} =
  registry.timestamps
  |> Enum.map(fn({guard, intervals}) -> {guard, ReposeRecord.full_minutes(intervals)} end)
  |> Enum.map(fn({guard, minutes}) -> Enum.map(minutes, &({guard, &1})) end)
  |> List.flatten()
  |> Enum.reduce(minutes, fn({guard, minute}, map) -> Map.update(map, minute, %{guard => 1}, fn(minute_map) -> Map.update(minute_map, guard, 1, &(&1 + 1)) end) end)
  |> Enum.to_list()
  |> Enum.map(&ReposeRecord.minute_max/1)
  |> Enum.max_by(fn({_ ,{_, count}}) -> count end)


IO.puts "Guard: #{guard}"
IO.puts "Minute: #{minute}"
IO.puts "Solution: #{guard * minute}"
