# rearrange the given train with help of your shunting station
# such that the desired train is obtained

defmodule Train do

  # wagons -> modeled as atoms
  # trains on tracks -> as lists of atoms
  # a train has no duplicate wagons (atoms)

  # state of a shunting station -> represented as a tuple with three elements:
  # 1. main: a list describing the train on track
  # 2-3. one and two: lists describing tracks

  # move is a binary tuple that describes how one state is transformed into another:
  # first element of a move is either :one or :two, second element is an integer
  # example: {:one, 2}, {:two, 2} and {:one, -3}

  # if move = {:one, n} & n > 0 ->
  # then the n right most wagons are moved from track "main" to track "one"
  # if there more than n wagons on track "main", the other wagons remain

  # if move = {:one, n} & n < 0 ->
  # then the n left most wagons are moved from track "one" to track "main"
  # if there more than n wagons on track "one", the other wagons remain

  # move {:one, 0} has no effect

  def test1() do
    a = Moves.single({:two, -1}, {[:a,:b],[:c, :d],[:e, :f]})
    b = Moves.single({:one,1},{[:a,:b],[],[]})
    IO.inspect(a)
    IO.inspect(b)
    :ok
  end

  def test2() do
    Moves.move([{:one,1},{:two,1},{:one,-1}],{[:a,:b],[],[]})
  end

  def test3() do
    a = Shunt.split([:a,:b,:c],:a)
    b = Shunt.split([:a,:b,:c],:b)
    IO.inspect(a)
    IO.inspect(b)
    :ok
  end

  def test4() do
    a = Shunt.find([:a,:b],[:b, :a])
    b = Shunt.find([:c,:a,:b],[:c,:b,:a])
    IO.inspect(a)
    IO.inspect(b)
    :ok
  end

  def test5() do
    Moves.move([{:one,1},{:two,1},{:one,-1},{:two,-1},{:one,1},{:two,0},{:one,-1},{:two, 0}],{[:a,:b],[],[]})
  end

  def test6() do
    Moves.move([{-3},{:two,0},{:one,1},{:two,1},{:one,-1},{:two, -1},{:one,1},{:two, 0},{:one,-1},{:two, 0}],{[:c,:a, :b],[],[]})
  end

  def test7() do
    IO.inspect(Shunt.few([:a,:b],[:b, :a]))
    IO.inspect(Shunt.few([:c,:a,:b],[:c,:b,:a]))
  end

  def test8() do
    IO.inspect(Shunt.compress([{:two,-1},{:one,1},{:one,-1},{:two,1}]))
  end
end

defmodule Moves do
  # a single move
  def single({:one, n}, {main, one, two}) do
    cond do
      n == 0 -> {main, one, two}
      n > 0 -> # from main to :one
        {Lists.take(main, length(main) - n), Lists.append(Lists.drop(main, length(main) - n), one), two}
      n < 0 -> # from :one to main
        {Lists.append(main, Lists.take(one, -n)), Lists.drop(one, -n), two}
    end
  end
  def single({:two, n}, {main, one, two}) do
    cond do
      n == 0 -> {main, one, two}
      n > 0 -> # from main to :two
        {Lists.take(main, length(main) - n), one, Lists.append(Lists.drop(main, length(main) - n), two)}
      n < 0 -> # from :two to main
        {Lists.append(main, Lists.take(two, -n)), one, Lists.drop(two, -n)}
    end
  end
  # several moves
  def move(moves, state) do
    case moves do
      [] -> IO.inspect([state])
      [h|t] -> IO.inspect([state|move(t, single(h, state))])
    end
  end
end

defmodule Shunt do
  # takes two trains xs (given train) and ys (the desired train)
  # returns a list of moves
  # xs and ys contain the same elements(wagons)
  # each wagon is unique

  def split(xs, y) do       # takes a list of wagons (xs) and the wagon (y)
  {Lists.take(xs, Lists.position(xs, y)-1), Lists.drop(xs, Lists.position(xs, y))} # returns the pair {hs,ts}
  end

  def find(given, desired) do
    case desired do
      [] -> []       # base case, if there are no wagons
      [head|tail] -> # we take the first wagon "head" from desired train
          {h, t} = IO.inspect(split(given, head)) # split the given train into head and tail
          moves = [{:one, length(t)+1}, {:two, length(h)}, {:one, -(length(t)+1)}, {:two, -length(h)}]
          list = Moves.move(moves, {given, [], []})
          {[ht|tt], [], []} = Enum.at(list, -1)
          Lists.append(moves, find(tt, tail))
    end
  end

  def few([h|t1], [h|t2]) do few(t1, t2) end
  def few(given, desired) do
    case desired do
      [] -> []
      [head|tail] ->
          {h, t} = split(given, head)
          moves = [{:one, length(t)+1}, {:two, length(h)}, {:one, -(length(t)+1)}, {:two, -length(h)}]
          list = Moves.move(moves, {given, [], []})
          {[ht|tt], [], []} = Enum.at(list, -1)
          Lists.append(moves, few(tt, tail))
      end
  end

  
  #def compress(ms) do
   # ns = rules(ms)
    #cond do
     # ns == ms -> ns
      #true -> compress(ns)
    #end
  #end
end

defmodule Lists do
  def take(xs, n) when n <= 0 do [] end
  def take(xs, n) do        # returns the list containing the first n elements of xs
    [h|t] = xs
    case xs do
      [] -> []
      [h|t] -> [h|take(t, n-1)]
    end
  end

  def drop(xs, n) do        # returns the list xs without its first n elements
    [h|t] = xs
    case n do
      [] -> []
      0 -> [h|t]
      1 -> t
      n -> drop(t, n-1)
    end
  end

  def append(xs, ys) do     # returns the list xs with the elements of ys appended
    xs ++ ys
  end

  def member(xs, y) do      # tests whether y is an element of xs, true/false
    Enum.member?(xs, y)
  end

  def position(xs, y) do    # returns the first postition of y in the list xs
    [h|t] = xs
    cond do
      h == y -> 1
      true -> position(t, y) + 1
    end
  end
end
