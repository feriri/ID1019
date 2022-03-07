defmodule Derivative do
    @type literal() :: {:num, number()} | {:var, atom()}
    @type expr() :: literal()
    | {:add, expr(), expr()}
    | {:mul, expr(), expr()}
    | {:exp, expr(), literal()}
    | {:ln, expr()}
    | {:div, expr(), expr()}
    | {:sqrt, expr()}
    | {:sin, expr()}
    | {:cos, expr()}
    
    def test1() do
        e = {:add,
                {:mul, {:num, 5}, {:var, :x}},
                {:num, 6}}
        d = deriv(e, :x)
        c = calc(d, :x, 1)
        IO.write("expression: #{pprint(e)}\n")
        IO.write("derivative: #{pprint(d)}\n")
        IO.write("simplified: #{pprint(simplify(d))}\n")
        IO.write("calculated: #{pprint(simplify(c))}\n")
        :ok
    end

    def test2() do
        e = {:add,
                {:exp, {:var, :x}, {:num, 4}},
                {:num, 12}}
        d = deriv(e, :x)
        c = calc(d, :x, 7)
        IO.write("expression: #{pprint(e)}\n")
        IO.write("derivative: #{pprint(d)}\n")
        IO.write("simplified: #{pprint(simplify(d))}\n")
        IO.write("calculated: #{pprint(simplify(c))}\n")
        :ok
    end

    def test3() do
        e = {:div, {:num, 1}, {:var, :x}}
        d = deriv(e, :x)
        c = calc(d, :x, 1)
        IO.write("expression: #{pprint(e)}\n")
        IO.write("derivative: #{pprint(d)}\n")
        IO.write("simplified: #{pprint(simplify(d))}\n")
        IO.write("calculated: #{pprint(simplify(c))}\n")
        :ok
    end

    def test4() do
        e = {:sqrt, {:var, :x}}
        d = deriv(e, :x)
        c = calc(d, :x, 4)
        IO.write("expression: #{pprint(e)}\n")
        IO.write("derivative: #{pprint(d)}\n")
        IO.write("simplified: #{pprint(simplify(d))}\n")
        IO.write("calculated: #{pprint(simplify(c))}\n")
        :ok
    end

    def test5() do
        e = {:ln, {:var, :x}}
        d = deriv(e, :x)
        c = calc(d, :x, 1)
        IO.write("expression: #{pprint(e)}\n")
        IO.write("derivative: #{pprint(d)}\n")
        IO.write("calculated: #{pprint(simplify(c))}\n")
        :ok
    end
    
    def test6() do
        e = {:sin, {:add, {:exp, {:var, :x}, {:num, 2}}, {:num, 4}}}
        d = deriv(e, :x)
        c = calc(d, :x, 2)
        IO.write("expression: #{pprint(e)}\n")
        IO.write("derivative: #{pprint(d)}\n")
        IO.write("simplified: #{pprint(simplify(d))}\n")
        IO.write("calculated: #{pprint(simplify(c))}\n")
        :ok
    end

    def deriv({:num, _}, _) do {:num, 0} end
    def deriv({:var, v}, v) do {:num, 1} end
    def deriv({:var, _}, _) do {:num, 0} end
    def deriv({:add, e1, e2}, v) do         # f'(x) + g'(x)
        {:add, deriv(e1, v), deriv(e2, v)}
    end 
    def deriv({:mul, e1, e2}, v) do         # f'(x).g(x) + f(x).g'(x)
        {:add, 
            {:mul, deriv(e1, v), e2},
            {:mul, e1, deriv(e2, v)}}
    end
    def deriv({:exp, e, {:num, n}}, v) do   # x^n  ->  nx^(n-1)
        {:mul,
            {:mul, {:num, n}, {:exp, e, {:num, n-1}}},
            deriv(e, v)}
    end
    def deriv({:div, e1, e2}, v) do         # f'(x).g(x) - f(x).g'(x) / (g(x))^2
        {:div,
            {:add, 
                {:mul, deriv(e1, v), e2},
            {:mul,
                {:mul, e1, deriv(e2, v)}, {:num, -1}}},
            {:exp, e2, {:num, 2}}}
    end
    def deriv({:sqrt, e}, v) do             # sqrt(x)  ->  (1/2).x^(-1/2) 
        {:mul,
            {:div, {:num, 1}, {:num, 2}},
            {:exp, e, {:mul, {:num, -1}, {:div, {:num, 1}, {:num, 2}}}}}
    end  
    def deriv({:ln, e}, v) do
        {:div, {:num, 1}, e}
    end
    def deriv({:sin, e}, v) do
        {:mul, deriv(e, v), {:cos, e}}
    end
    def deriv({:cos, e}, v) do
        {:mul, deriv(e, v), {:sin, e}}
    end

    def calc({:num, n}, _, _) do {:num, n} end
    def calc({:var, v}, v, n) do {:num, n} end
    def calc({:var, v}, _, _) do {:var, v} end
    def calc({:add, e1, e2}, v, n) do
        {:add, calc(e1, v, n), calc(e2, v, n)}
    end
    def calc({:mul, e1, e2}, v, n) do
        {:mul, calc(e1, v, n), calc(e2, v, n)}
    end
    def calc({:exp, e1, e2}, v, n) do
        {:exp, calc(e1, v, n), calc(e2, v, n)}
    end
    def calc({:div, e1, e2}, v, n) do
        {:div, calc(e1, v, n), calc(e2, v, n)}
    end
    def calc({:sqrt, e}, v, n) do
        {:sqrt, calc(e, v, n)}
    end
    def calc({:sin, e}, v, n) do
        {:sin, calc(e, v, n)}
    end
    def calc({:cos, e}, v, n) do
        {:cos, calc(e, v, n)}
    end

    def simplify({:add, e1, e2}) do
        simplify_add(simplify(e1), simplify(e2))
    end
    def simplify({:mul, e1, e2}) do
        simplify_mul(simplify(e1), simplify(e2))
    end
    def simplify({:exp, e1, e2}) do
        simplify_exp(simplify(e1), simplify(e2))
    end
    def simplify({:div, e1, e2}) do
        simplify_div(simplify(e1), simplify(e2))
    end
    def simplify({:sqrt, e}) do
        simplify_sqrt(simplify(e))
    end
    def simplify({:sin, e}) do
        simplify_sin(simplify(e))
    end
    def simplify({:cos, e}) do
        simplify_cos(simplify(e))
    end
    def simplify(e) do e end

    def simplify_add({:num, 0}, e2) do e2 end
    def simplify_add(e1, {:num, 0}) do e1 end
    def simplify_add({:num, n1}, {:num, n2}) do {:num, n1 + n2} end
    def simplify_add(e1, e2) do {:add, e1, e2} end

    def simplify_mul({:num, 0}, _) do {:num, 0} end
    def simplify_mul(_, {:num, 0}) do {:num, 0} end
    def simplify_mul({:num, 1}, e2) do e2 end
    def simplify_mul(e1, {:num, 1}) do e1 end
    def simplify_mul({:num, n1}, {:num, n2}) do {:num, n1 * n2} end
    def simplify_mul(e1, e2) do {:mul, e1, e2} end
    
    def simplify_exp(_, {:num, 0}) do {:num, 1} end
    def simplify_exp(e1, {:num, 1}) do e1 end
    def simplify_exp({:num, n1}, {:num, n2}) do {:num, :math.pow(n1, n2)} end
    def simplify_exp(e1, e2) do {:exp, e1, e2} end

    def simplify_div({:num, 0}, _) do {:num, 0} end
    def simplify_div(e1, {:num, 1}) do e1 end
    def simplify_div({:num, n1}, {:num, n2}) do {:num, n1 / n2} end
    def simplify_div(e1, e2) do {:div, e1, e2} end

    def simplify_sqrt({:num, 0}) do {:num, 0} end
    def simplify_sqrt({:num, 1}) do {:num, 1} end
    def simplify_sqrt({:num, n}) do {:num, :math.sqrt(n)} end
    def simplify_sqrt(e) do {:sqrt, e} end

    def simplify_sin({:num, n}) do {:num, :math.sin(n)} end
    def simplify_sin(e) do {:sin, e} end

    def simplify_cos({:num, n}) do {:num, :math.cos(n)} end
    def simplify_cos(e) do {:cos, e} end

    def pprint({:num, n}) do "#{n}" end
    def pprint({:var, v}) do "#{v}" end
    def pprint({:add, e1, e2}) do "(#{pprint(e1)} + #{pprint(e2)})" end
    def pprint({:mul, e1, e2}) do "#{pprint(e1)} * #{pprint(e2)}" end
    def pprint({:exp, e1, e2}) do "#{pprint(e1)}^(#{pprint(e2)})" end
    def pprint({:div, e1, e2}) do "(#{pprint(e1)} / #{pprint(e2)})" end
    def pprint({:sqrt, e}) do "sqrt(#{pprint(e)})" end
    def pprint({:ln, e}) do "ln(#{pprint(e)})" end
    def pprint({:sin, e}) do "sin(#{pprint(e)})" end
    def pprint({:cos, e}) do "cos(#{pprint(e)})" end
end
