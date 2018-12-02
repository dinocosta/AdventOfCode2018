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
end

{twice, thrice} =
  "2.input.txt"
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Stream.map(&String.codepoints/1)
  |> Stream.map(&Enum.sort/1)
  |> Enum.reduce({0, 0}, fn(line, {twice, thrice}) -> {twice + IMS.has_repeating_letters?(line), thrice + IMS.has_repeating_letters?(line, 3)} end)

IO.puts(twice * thrice)
