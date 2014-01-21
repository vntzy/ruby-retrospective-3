module Graphics
        class Canvas
                def initialize (width, height)
                        @width = width
                        @height = height
                        @pixels = []
                end

                def width
                        @width
                end

                def height
                        @height
                end

                def set_pixel (x, y)
                        @pixels = (@pixels + [[x, y]]).uniq
                end

                def pixel_at? (x, y)
                        @pixels.include? [x, y]
                end

                def draw (form)
                        @pixels = (@pixels + form.pixels).uniq
                end

                def pixels
                        @pixels
                end

                def render_as (renderer)
                        renderer.print(@pixels, @width, @height)
                end
        end

        module Renderers
                class Ascii
                        def self.print(pixels, columns, rows)
                                result = ""
                                matrix = 0.upto(rows-1).to_a.product(0.upto(columns-1).to_a)
                                matrix.each do |i|
                                        (pixels.include? i.reverse) ? result << "@" : result << "-"
                                end
                                rows.downto(1).each { |row| result.insert(columns*row, "\n") }
                                result.chop
                        end
                end

                class Html
                        def self.print(pixels, columns, rows)
                                result, html = "", '  <!DOCTYPE html>
  <html>
  <head>
    <title>Rendered Canvas</title>
    <style type="text/css">
      .canvas {
        font-size: 1px;
        line-height: 1px;
      }
      .canvas * {
        display: inline-block;
        width: 10px;
        height: 10px;
        border-radius: 5px;
      }
      .canvas i {
        background-color: #eee;
      }
      .canvas b {
        background-color: #333;
      }
    </style>
  </head>
  <body>
    <div class="canvas">
'
                           matrix = 0.upto(rows-1).to_a.product(0.upto(columns-1).to_a)
                        matrix.each do |i|
                         (pixels.include? i.reverse) ? result << "<b></b>" : result << "<i></i>"
                        end
                        rows.downto(1).each { |row| result.insert(columns*7*row, "<br>\n") }
                        html << result.chomp("<br>\n") << "\n" <<    '</div>
  </body>
  </html>'
                        end
                end
        end

        class Point
                def initialize (x, y)
                        @x = x
                        @y = y
                        @pixels = [[x, y]]
                end

                def x
                        @x
                end

                def y
                        @y
                end

                def pixels
                        @pixels
                end

                def ==(other)
                        @x == other.x and @y = other.y ? true : false
                end

                def eql?(other)
                        @x == other.x and @y = other.y ? true : false
                end

                def hash
                        hash_code = 0
                        @pixels.uniq.sort.flatten.each { |i| hash_code = 10*hash_code + i}
                        hash_code.hash
                end
        end

        class Line
                def initialize (from, to)
                        @from = Point.new(from.x, from.y)
                        @to = Point.new(to.x, to.y)
                        @pixels = [[@from.x, @from.y]]
                        self.rasterize
                end

                def from
                        if @from.x < @to.x then return @from end
                        if @from.x > @to.x then return @to end
                        @from.y < @to.y ? @from : @to
                end

                def to
                        if @from.x > @to.x then return @from end
                        if @from.x < @to.x then return @to end
                        @from.y > @to.y ? @from : @to
                end

                def ==(other)
                        @from == other.from and @to == other.to ? true : false
                end

                def eql?(other)
                        @from == other.from and @to == other.to ? true : false
                end

                def pixels
                        @pixels
                end

                def hash
                        hash_code = 0
                        @pixels.uniq.sort.flatten.each { |i| hash_code = 10*hash_code + i}
                        hash_code.hash
                end

                protected
                def rasterize
                        x, y = @from.x, @from.y
                        delta_x, delta_y = @to.x - x, @to.y - y
                        until x.round == @to.x and y.round == @to.y do
                                x = x + delta_x.to_f/[delta_x.abs, delta_y.abs].max
                                y = y + delta_y.to_f/[delta_x.abs, delta_y.abs].max
                                @pixels << [x.round, y.round]
                        end
                end
        end

        class Rectangle
                def initialize (p_1, p_2)
                        @top_left = Point.new(([p_1.x, p_2.x].min), ([p_1.y, p_2.y].min))
                        @top_right = Point.new(([p_1.x, p_2.x].max), ([p_1.y, p_2.y].min))
                        @bottom_left = Point.new(([p_1.x, p_2.x].min), ([p_1.y, p_2.y].max))
                        @bottom_right = Point.new(([p_1.x, p_2.x].max), ([p_1.y, p_2.y].max))
                        self.set_pixels
                end

                def left
                        @top_left
                end

                def right
                        @bottom_right
                end

                def top_left
                        @top_left
                end
                def top_right
                        @top_right
                end
                def bottom_left
                        @bottom_left
                end
                def bottom_right
                        @bottom_right
                end

                def pixels
                        @pixels
                end

                def ==(other)
                        @pixels.uniq.sort == other.pixels.uniq.sort
                end
                def eql?(other)
                        @pixels.uniq.sort == other.pixels.uniq.sort
                end

                def hash
                        hash_code = 0
                        @pixels.uniq.sort.flatten.each { |i| hash_code = 10*hash_code + i}
                        hash_code.hash
                end

                protected
                def set_pixels
                        @pixels = Line.new(@top_left, @top_right).pixels
                        @pixels = @pixels + Line.new(@top_right, @bottom_right).pixels
                        @pixels = @pixels + Line.new(@bottom_right, @bottom_left).pixels
                        @pixels = (@pixels + Line.new(@bottom_left, @top_left).pixels).uniq
                end
        end
end