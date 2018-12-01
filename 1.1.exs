result =
  "1.input.txt"
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Stream.map(&String.to_integer/1)
  |> Enum.reduce(0, &Kernel.+/2)

IO.puts(result)
