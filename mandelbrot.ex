defmodule Cmplx do
    import Kernel, except: [abs: 1]
    @doc """
    re represents the real part
    im represents the imaginary part
    """
    def new(re, im) do {re, im} end

    def add({ar, ai}, {br, bi}) do  # (a + bi) + (c + di) = (a + c) + (b + d)i
        {ar + br, ai + bi}
    end

    def sqr({re, im}) do            # (a + bi)^2 = (a^2 - b^2) + (2ab)i
        {:math.pow(re, 2) - :math.pow(im, 2), 2*re*im}
    end

    def abs({re, im}) do            # |z| = sqr(a^2 + b^2)
        :math.sqrt(:math.pow(re, 2) + :math.pow(im, 2))
    end
end

defmodule Mandel do
    @doc """
    generates an image
    """
    def mandelbrot(width, height, x, y, k, depth) do
        trans = fn(w, h) ->
            Cmplx.new(x + k * (w - 1), y - k * (h - 1))
        end
        rows(width, height, trans, depth, [])
    end

    defp rows(width, height, trans, depth, rows) do
        trans = fn(x, y) ->
            c = trans.(x, y)
            d = Brot.mandelbrot(c, depth)
            Color.convert(d, depth)
        end
        Enum.map(1..height, fn y ->
            Enum.map(1..width, fn x ->
                trans.(x, y)
            end)
        end)
    end
end

defmodule Brot do
    @doc """
    calculate the mandelbrot value of complex value c
    with a maximum iteration of limit. Returns 0..(m - 1).
    """
    def mandelbrot(c, limit) do
        origo = Cmplx.new(0, 0)
        brot(0, origo, c, limit)
    end

    @doc """
    given the complex number c and the maximum number
    of iterations limit return the value n at which
    |zn| > 2 or 0 if it does not for any i < limit
    """
    defp brot(n, zn, c, limit) do
        cond do
            n == limit -> 0
            Cmplx.abs(zn) <= 2 ->
                znext = Cmplx.add(Cmplx.sqr(zn), c)
                brot(n+1, znext, c, limit)
            true > 2 -> n
        end
    end
end

defmodule Color do
    @doc """
    Convert a scalar, from 0 to max, to a suitabe color
    represented as {r ,g ,b} where each element is 0..255.
    """
    def convert(n, limit) do
        a = n/limit*4
        x = trunc(a)
        y = trunc(255 * (a - x))
       case x do
            0 -> {y, 0, y}
            1 -> {255, y, 255}
            2 -> {255 - y, y, 255}
            3 -> {y, 255, y}
            4 -> {255, y, 255 - y}
        end
    end
end

defmodule PPM do
    @doc """
    The image is a list of rows, each row a list
    of tuples {R,G,B}. The RGB values are 0-255.
    """
    def write(name, image) do
        height = length(image)
        width = length(List.first(image))
        {:ok, fd} = File.open(name, [:write])
        IO.puts(fd, "P6")
        IO.puts(fd, "#generated by ppm.ex")
        IO.puts(fd, "#{width} #{height}")
        IO.puts(fd, "255")
        rows(image, fd)
        File.close(fd)
    end

    defp rows(rows, fd) do
        Enum.each(rows, fn(r) ->
          colors = row(r)
          IO.write(fd, colors)
        end)
    end

    defp row(row) do
        List.foldr(row, [], fn({r, g, b}, a) ->
          [r, g, b | a]
        end)
    end
end

defmodule Test do
    def demo() do
        small(-2.6, 1.2, 1.2)
    end

    def small(x0, y0, xn) do
        width = 960
        height = 560
        depth = 64
        k = (xn - x0) / width
        image = Mandel.mandelbrot(width, height, x0, y0, k, depth)
        PPM.write("small.ppm", image)
    end

    def test_cmplx() do
        z1 = Cmplx.new(3, 4)
        z2 = Cmplx.new(2, 5)
        add = Cmplx.add(z1, z2)
        sqr1 = Cmplx.sqr(z1)
        sqr2 = Cmplx.sqr(z2)
        abs1 = Cmplx.abs(z1)
        abs2 = Cmplx.abs(z2)
        IO.puts("z1 = #{inspect(z1)}, z2 = #{inspect(z2)}")
        IO.puts("add(z1, z2) = #{inspect(add)}")
        IO.puts("sqr(z1) = #{inspect(sqr1)}, sqr(z2) = #{inspect(sqr2)}")
        IO.puts("abs(z1) = #{inspect(abs1)}, abs(z2) = #{inspect(abs2)}")
    end

    def test_brot() do
        IO.puts"thirty:"
        IO.inspect(Brot.mandelbrot(Cmplx.new(0.8, 0), 30))
        IO.inspect(Brot.mandelbrot(Cmplx.new(0.5, 0), 30))
        IO.inspect(Brot.mandelbrot(Cmplx.new(0.3, 0), 30))
        IO.inspect(Brot.mandelbrot(Cmplx.new(0.27, 0), 30))
        IO.inspect(Brot.mandelbrot(Cmplx.new(0.26, 0), 30))
        IO.inspect(Brot.mandelbrot(Cmplx.new(0.255, 0), 30))
        IO.puts"fifty:"
        IO.inspect(Brot.mandelbrot(Cmplx.new(0.8, 0), 50))
        IO.inspect(Brot.mandelbrot(Cmplx.new(0.5, 0), 50))
        IO.inspect(Brot.mandelbrot(Cmplx.new(0.3, 0), 50))
        IO.inspect(Brot.mandelbrot(Cmplx.new(0.27, 0), 50))
        IO.inspect(Brot.mandelbrot(Cmplx.new(0.26, 0), 50))
        IO.inspect(Brot.mandelbrot(Cmplx.new(0.255, 0), 50))
        :ok
    end
end