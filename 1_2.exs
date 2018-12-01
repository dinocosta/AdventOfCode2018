defmodule ChronalCalibration do
  def first_repeating_frequency(changes, frequency \\ 0, frequencies \\ %{})
  def first_repeating_frequency([change | changes], frequency, frequencies) do
    new_frequency = frequency + change

    case Map.get(frequencies, new_frequency, 0) == 1 do
      true -> new_frequency
      false -> first_repeating_frequency(changes ++ [change], new_frequency, Map.put(frequencies, new_frequency, 1))
    end
  end
end

result =
  "1_1_input.txt"
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Enum.map(&String.to_integer/1)
  |> ChronalCalibration.first_repeating_frequency()

IO.puts(result)
