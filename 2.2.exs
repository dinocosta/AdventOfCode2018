defmodule IMS do
  @doc """
  Determines wether or not the string
  as a specific number of repeating letters.

  Returns 1 if it has repeating letters, 0 otherwise.
  """
  @spec has_repeating_letters?(List.t, Integer.t) :: Integer.t
  def has_repeating_letters?(letters, number \\ 2)
  def has_repeating_letters?([], _), do: 0
  def has_repeating_letters?([letter | letters], number) do
    {repeating_letters, remaining_letters} = Enum.split_while(letters, fn(x) -> x == letter end)
    case length(repeating_letters) == (number - 1) do
      true -> 1
      false -> has_repeating_letters?(remaining_letters, number)
    end
  end

  def similar_ids([]), do: []
  def similar_ids([head | tail]),
    do: [{head, similar_ids(head, tail)} | similar_ids(tail)]

  def similar_ids(_, []), do: []
  def similar_ids(id, [head | tail]) do
    case is_similar?(id, head) do
      true -> [head | similar_ids(id, tail)]
      false -> similar_ids(id, tail)
    end
  end

  @doc """
  Returns true if two strings differ between each other
  by only one letter.
  Returns false otherwise.
  """
  @spec is_similar?(String.t, String.t) :: boolean
  def is_similar?(a, b), do: similar?(String.codepoints(a), String.codepoints(b))

  @spec similar?(List.t, List.t, Integer.t) :: boolean
  def similar?(letters_a, letters_b, difference \\ 0)
  def similar?(_, _, 2), do: false
  def similar?([], [], 0), do: true
  def similar?([], [], 1), do: true
  def similar?([letter_a | letters_a], [letter_b | letters_b], difference) do
    case letter_a != letter_b do
      true -> similar?(letters_a, letters_b, difference + 1)
      false -> similar?(letters_a, letters_b, difference)
    end
  end
end

[{id, [matching_id]}] =
  "2.input.txt"
  |> File.stream!()
  |> Enum.map(&String.trim/1)
  |> IMS.similar_ids()
  |> Enum.filter(fn {_, ids} -> length(ids) > 0 end)

result =
  id
  |> String.myers_difference(matching_id)
  |> Enum.filter(fn {key, value} -> key == :eq end)
  |> Keyword.values()
  |> Enum.join()

IO.puts(result)
