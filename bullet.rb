class Bullet
SPEED = 5
  attr_reader :x, :y, :radius
  def initialize(map, x, y, angle)
    @x = x
    @y = y
    @angle = angle
    @image = Gosu::Image.new(map, 'images/torpedo_50px.png', false)
    @sound =
    @radius = 0
    @map = map
  end

  def move
    @x += Gosu.offset_x(@angle, SPEED)
    @y += Gosu.offset_y(@angle, SPEED)
  end

  def draw
    @image.draw_rot(@x - @radius, @y - @radius, 1, @angle)
  end

  def onscreen?
    right = (@map.width * 3) + 300
    left = -@radius
    top = -@radius
    bottom = @map.height * 2
    @x > left and @x < right and @y > top and @y < bottom
  end
end
