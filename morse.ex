defmodule Morse do
  def test() do

    testname = 'farzaneh'

    test1 = '.- .-.. .-.. ..-- -.-- --- ..- .-. ..-- -... .- ... . ..-- .- .-. . ..-- -... . .-.. --- -. --. ..-- - --- ..-- ..- ... '

    test2 = '.... - - .--. ... ---... .----- .----- .-- .-- .-- .-.-.- -.-- --- ..- - ..- -... . .-.-.- -.-. --- -- .----- .-- .- - -.-. .... ..--.. ...- .----. -.. .--.-- ..... .---- .-- ....- .-- ----. .--.-- ..... --... --. .--.-- ..... ---.. -.-. .--.-- ..... .---- '

    IO.inspect(encode(testname))
    IO.inspect(decode(test1))
    IO.inspect(decode(test2))
    :ok
  end

  def encode_table(tree) do codes(tree, []) end
  def codes({:node, ascii, short, long}, list) do
    char = [{ascii, list}]
    cond do
      short == nil && long == nil -> char
      long == nil -> char ++ codes(short, list ++ [?.])
      short == nil ->  char ++ codes(long, list ++ [?-])
      true ->
        char ++ codes(long, list ++ [?-])
        ++ codes(short, list ++ [?.])
    end
  end

  def encode(text) do
    table = encode_table(morse())
    encode(text, table)
  end

  def encode(list, table) do
    case list do
      [] -> []
      [h|t] ->
        {_, code} = Enum.find(table, fn({c, l})-> c==h end)
        code ++ [?\s] ++ encode(t, table)
    end
  end

  def decode(signal) do
    table = morse()
    decode(signal, table)
  end

  def decode(signal, table) do
    case signal do
      [] -> []
      _ ->
          {c, r} = translate(table, signal)
          [c|decode(r, table)]
    end
  end

  def translate({:node, char, _, _}, []), do: {char, []}
  def translate({:node, char, long, short}, [h|t]) do
    case h do
      ?. -> translate(short, t)
      ?- -> translate(long, t)
      ?\s -> {char, t}
      _ ->  {?*, t}
    end
  end

  # Morse decoding tree
  def morse() do
    {:node, :na,
      {:node, 116,
        {:node, 109,
          {:node, 111,
            {:node, :na, {:node, 48, nil, nil}, {:node, 57, nil, nil}},
            {:node, :na, nil, {:node, 56, nil, {:node, 58, nil, nil}}}},
          {:node, 103,
            {:node, 113, nil, nil},
            {:node, 122,
              {:node, :na, {:node, 44, nil, nil}, nil},
              {:node, 55, nil, nil}}}},
        {:node, 110,
          {:node, 107, {:node, 121, nil, nil}, {:node, 99, nil, nil}},
          {:node, 100,
            {:node, 120, nil, nil},
            {:node, 98, nil, {:node, 54, {:node, 45, nil, nil}, nil}}}}},
      {:node, 101,
        {:node, 97,
          {:node, 119,
            {:node, 106,
              {:node, 49, {:node, 47, nil, nil}, {:node, 61, nil, nil}},
              nil},
            {:node, 112,
              {:node, :na, {:node, 37, nil, nil}, {:node, 64, nil, nil}},
              nil}},
          {:node, 114,
            {:node, :na, nil, {:node, :na, {:node, 46, nil, nil}, nil}},
            {:node, 108, nil, nil}}},
        {:node, 105,
          {:node, 117,
            {:node, 32,
              {:node, 50, nil, nil},
              {:node, :na, nil, {:node, 63, nil, nil}}},
            {:node, 102, nil, nil}},
          {:node, 115,
            {:node, 118, {:node, 51, nil, nil}, nil},
            {:node, 104, {:node, 52, nil, nil}, {:node, 53, nil, nil}}}}}}
  end
end
