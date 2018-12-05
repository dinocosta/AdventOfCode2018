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

registry = "4.input.txt"
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.sort()
  |> Enum.reduce(%{guard: nil, timestamps: %{}}, fn(string, registry) -> Registry.update(registry, string) end)

{guard, minutes} =
  registry.timestamps
  |> Enum.max_by(fn({_, minutes}) -> minutes |> Enum.chunk_every(2) |> Enum.map(fn([a, b]) -> b - a end) |> Enum.sum end)

{minute, _} =
  minutes
  |> Enum.chunk_every(2)
  |> Enum.map(fn([a, b]) -> Enum.to_list(a..(b - 1)) end)
  |> List.flatten()
  |> Enum.reduce(%{}, fn(minute, minutes) -> Map.update(minutes, minute, 1, &(&1 + 1)) end)
  |> Enum.max_by(fn({_, count}) -> count end)

IO.puts "Guard: #{guard}"
IO.puts "Minute: #{minute}"
IO.puts "Solution: #{guard * minute}"
