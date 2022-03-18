defmodule Emulator do

  def test() do
    code =
    [{:addi, 1, 0, 5}, # $1 <- 5
    {:lw, 2, 0, :arg}, # $2 <- data[:arg]
    {:add, 4, 2, 1}, # $4 <- $2 + $1
    {:addi, 5, 0, 1}, # $5 <- 1
    {:label, :loop},
    {:sub, 4, 4, 5}, # $4 <- $4 - $5
    {:out, 4}, # out $4
    {:bne, 4, 0, :loop}, # branch if not equal
    {:halt}]
  
    data = [{:arg, 12}]
    run({:prgm, code, data})
  end

  def run(prgm) do
    {code, data} = Program.load(prgm)
    out = Out.new()
    reg = Register.new()
    run(0, code, data, reg, out)
  end

  def run(pc, code, mem, reg, out) do
    next = Program.read(code, pc)
    case next do

      {:halt} ->
    Out.close(out)

      {:out, rs} ->
    a = Register.read(reg, rs)
    run(pc+4, code, mem, reg, Out.put(out,a))
	
      {:add, rd, rs, rt} ->
    a = Register.read(reg, rs)
    b = Register.read(reg, rt)
    reg = Register.write(reg, rd, a + b)
    run(pc+4, code, mem, reg, out)

      {:sub, rd, rs, rt} ->
    a = Register.read(reg, rs)
    b = Register.read(reg, rt)
    reg = Register.write(reg, rd, a - b)
    run(pc+4, code, mem, reg, out)

      {:addi, rd, rs, imm} ->
    a = Register.read(reg, rs)
    reg = Register.write(reg, rd, a + imm)
    run(pc+4, code, mem, reg, out)

      {:beq, rs, rt, imm} ->
	  a = Register.read(reg, rs)
    b = Register.read(reg, rt)
    pc = if a == b do  pc+imm else pc end
    run(pc+4, code, mem, reg, out)

      {:bne, rs, rt, imm} ->
    a = Register.read(reg, rs)
    b = Register.read(reg, rt)
    pc = if a != b do mem[imm] else pc+4 end
    run(pc, code, mem, reg, out)

      {:lw, rd, rs, imm} ->
    val = Memory.read(mem, imm)
    reg = Register.write(reg, rd, val)
    run(pc+4, code, mem, reg, out)
      
      {:sw, rs, rt, imm} ->
    vs = Register.read(reg, rs)
    vt = Register.read(reg, rt)		
    addr = vt + imm
    mem = Memory.write(mem, addr, vs)
    run(pc+4, code, mem, reg, out)

      {:label, arg} ->
    mem = [{arg, pc}| mem]
    run(pc+4, code, mem, reg, out)

    end
  end
end

defmodule Memory do

  def new() do
    new([])
  end    

  def new(segments) do
    f = fn({start, data}, layout) ->
      last = start +  length(data) -1      
      Enum.zip(start..last, data) ++ layout
    end
    layout = List.foldr(segments, [], f)
    {:mem, Map.new(layout)}
  end

  def read(mem, i) do
    mem[i]
  end

  def write({:mem, mem}, i, v) do
    {:mem, Map.put(mem, i, v)}
  end  
end

defmodule Out do

  def new() do  [] end

  def put(out, a) do [a|out] end

  def close(out) do Enum.reverse(out) end

end

defmodule Program do

def load(prgm) do
  {:prgm, code, data} = prgm
  {code, data}
end

def read(code, pc) do
  Enum.at(code, div(pc, 4))
end
end

defmodule Register do

  def new() do
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
  end
  
  def read(  _, 0) do 0 end  
  def read(reg, i) do elem(reg, i) end

  def write(reg, 0, _) do reg end
  def write(reg, i, val) do put_elem(reg, i, val) end  
end

defmodule Test do

  def test() do
    code = Program.assemble(demo())
    mem = Memory.new([])
    out = Out.new()
    Emulator.run(code, mem, out)
  end

  def demo() do
    [{:addi, 1, 0, 5}, # $1 <- 5
    {:lw, 2, 0, :arg}, # $2 <- data[:arg]
    {:add, 4, 2, 1}, # $4 <- $2 + $1
    {:addi, 5, 0, 1}, # $5 <- 1
    {:label, :loop},
    {:sub, 4, 4, 5}, # $4 <- $4 - $5
    {:out, 4}, # out $4
    {:bne, 4, 0, :loop}, # branch if not equal
    :halt]
  end
end