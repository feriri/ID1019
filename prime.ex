defmodule First do

  def range_first(limit) do
    sieve1(Enum.to_list(2..limit), [])
  end

  defp sieve1(c, p) do 
    case c do
      [] -> []
      [h|t] -> [h|sieve1(Enum.filter(t, fn(t) ->
                                            rem(t, h) != 0 end), p)]
    end
  end

end

defmodule Second do

  def range_second(limit) do
    sieve2(Enum.to_list(2..limit), [])
  end

  defp sieve2(c, p) do
    case c do
      [] -> p
      [h|t] ->
      cond do
        Enum.any?(p, &(rem(h, &1) == 0)) == false ->
                                            sieve2(t, p ++ [h])
        true -> sieve2(t, p)
      end
    end
  end

end

defmodule Third do

  def range_third(limit) do
   sieve3(Enum.to_list(2..limit), [])
    |> Enum.reverse
  end

  defp sieve3(c, p) do
    case c do
      [] -> p
      [h|t] ->
      cond do
        Enum.any?(p, &(rem(h, &1) == 0)) == false ->
                                          sieve3(t, [h|p])
        true -> sieve3(t, p)
      end
    end
  end

end

defmodule Benchmark do
  def bench() do bench(20) end

  def bench(l) do

    n = [500, 1000, 2000, 5000, 10000]

    bench = fn(n) ->
      first = fn(n) -> First.range_first(n) end
      second = fn(n) -> Second.range_second(n) end
      third = fn(n) -> Third.range_third(n) end
      time = fn(f)->
        elem(:timer.tc(fn  -> loop(l, fn -> f.(n) end) end),0)
      end        

      tf = time.(first)
      ts = time.(second)
      tt = time.(third)

      IO.write("#{n} & #{tf} & #{ts} & #{tt}\n")
    end
    Enum.map(n, bench)
    :ok
  end

  def loop(0,_) do :ok end
  def loop(n, f) do
    f.()
    loop(n-1, f)
  end
end

#  def bench(n) do
#    s1= NaiveDateTime.utc_now
#    First.range(n)
#    e1 = NaiveDateTime.utc_now
#    tot1 = NaiveDateTime.diff(e1, s1, :microsecond)

#    s2= NaiveDateTime.utc_now
#    Second.range_second(n)
#    e2= NaiveDateTime.utc_now
#    tot2 = NaiveDateTime.diff(e2, s2, :microsecond)

#    s3= NaiveDateTime.utc_now
#    Second.range_second(n)
#    e3= NaiveDateTime.utc_now
#    tot3 = NaiveDateTime.diff(e3, s3, :microsecond)
     
#    IO.puts("First:")
#    IO.inspect(tot1)
#    IO.puts("Second:")
#    IO.inspect(tot2)
#    IO.puts("Third:")
#    IO.inspect(tot3)
#    :ok
#  end